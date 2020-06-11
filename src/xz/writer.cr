# A write-only `IO` object to compress data in the xz format.
#
# Instances of this class wrap another `IO` object. When you write to this
# instance, it compresses the data and writes it to the underlying `IO`.
#
# NOTE: unless created with a block, `close` must be invoked after all
# data has been written to a `Gzip::Writer` instance.
#
# ### Example: compress a file
#
# ```
# require "xz"
#
# File.write("file.txt", "abcd")
#
# File.open("./file.txt", "r") do |input_file|
#   File.open("./file.xz", "w") do |output_file|
#     Compress::XZ::Writer.open(output_file) do |xz|
#       IO.copy(input_file, xz)
#     end
#   end
# end
# ```
class Compress::XZ::Writer < IO
  # If `#sync_close?` is `true`, closing this IO will close the underlying IO.
  property? sync_close : Bool

  # Creates an instance of XZ::Writer. `close` must be invoked after all data
  # has written.
  def initialize(@output : IO, preset : Int32 = PRESET::DEFAULT_COMPRESSION, @sync_close : Bool = false)
    unless 0 <= preset <= 9
      raise ArgumentError.new("Invalid preset level: #{preset} (must be in 0..9)")
    end

    @buf = uninitialized UInt8[4096] # output buffer
    @stream = LZMA::Stream.new
    @stream.avail_in = 0
    @stream.next_in = Pointer(UInt8).null
    @stream.next_out = @buf.to_unsafe
    @stream.avail_out = @buf.size.to_u32

    # alloc = LZMA::Allocator.new
    # alloc.alloc = LZMA::AllocFunc.new { |_, items, size| GC.malloc(items * size) }
    # alloc.free = LZMA::FreeFunc.new { |_, address| GC.free(address) }
    # @stream.allocator = pointerof(alloc)
    @closed = false
    ret = LZMA.easy_encoder(pointerof(@stream), preset, LZMA::Check::CheckCrc64)
    raise CompressionError.new(ret) unless ret.ok?
  end

  # Creates a new writer to the given *filename*.
  def self.new(filename : String, preset : Int32 = PRESET::DEFAULT_COMPRESSION)
    new(::File.new(filename, "w"), preset: level, sync_close: true)
  end

  # Creates a new writer to the given *io*, yields it to the given block,
  # and closes it at the end.
  def self.open(io : IO, preset : Int32 = PRESET::DEFAULT_COMPRESSION, sync_close = false)
    writer = new(io, preset: preset, sync_close: sync_close)
    yield writer ensure writer.close
  end

  # Creates a new writer to the given *filename*, yields it to the given block,
  # and closes it at the end.
  def self.open(filename : String, preset : Int32 = PRESET::DEFAULT_COMPRESSION)
    writer = new(filename, preset: preset)
    yield writer ensure writer.close
  end

  # Creates a new writer for the given *io*, yields it to the given block,
  # and closes it at its end.
  def self.open(io : IO, preset : Int32 = PRESET::DEFAULT_COMPRESSION, sync_close : Bool = false)
    writer = new(io, preset: preset, sync_close: sync_close)
    yield writer ensure writer.close
  end

  # Always raises `IO::Error` because this is a write-only `IO`.
  def read(slice : Bytes)
    raise "Can't read from XZ::Writer"
  end

  # See `IO#write`.
  def write(slice : Bytes) : Int64
    check_open

    return 0i64 if slice.empty?

    @stream.next_in = slice.to_unsafe
    @stream.avail_in = slice.size
    do_action LZMA::Action::Run
    slice.size.to_i64
  end

  # See `IO#flush`.
  def flush
    return if @closed

    do_action LZMA::Action::FullFlush
  end

  # Closes this writer. Must be invoked after all data has been written.
  def close
    return if @closed
    @closed = true

    @stream.avail_in = 0
    @stream.next_in = Pointer(UInt8).null
    do_action LZMA::Action::Finish
    LZMA._end(pointerof(@stream))
    @output.close if @sync_close
  end

  # Returns `true` if this IO is closed.
  def closed?
    @closed
  end

  # :nodoc:
  def inspect(io : IO) : Nil
    to_s(io)
  end

  private def do_action(action)
    loop do
      ret = LZMA.code(pointerof(@stream), action)
      if (@stream.avail_out == 0 || ret.stream_end?)
        size = @buf.size - @stream.avail_out
        @output.write(@buf.to_slice[0, size]) if size > 0
        @stream.next_out = @buf.to_unsafe
        @stream.avail_out = @buf.size.to_u32
      end
      raise CompressionError.new(ret) unless ret.ok? || ret.stream_end?
      break if @stream.avail_out != 0 || ret.stream_end?
    end
  end
end
