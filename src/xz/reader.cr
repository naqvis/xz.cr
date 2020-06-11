# A read-only `IO` object to decompress data in the XZ format.
#
# Instances of this class wrap another IO object. When you read from this instance
# instance, it reads data from the underlying IO, decompresses it, and returns
# it to the caller.
# ## Example: decompress an xz file
# ```crystal
# require "xz"

# string = File.open("file.xz") do |file|
#    Compress::XZ::Reader.open(file) do |xz|
#      xz.gets_to_end
#    end
# end
# pp string
# ```

class Compress::XZ::Reader < IO
  LZMA_CONCATENATED = 0x08
  include IO::Buffered

  # If `#sync_close?` is `true`, closing this IO will close the underlying IO.
  property? sync_close : Bool

  # Returns `true` if this reader is closed.
  getter? closed = false

  # Peeked bytes from the underlying IO
  @peek : Bytes?

  # Creates an instance of Flate::Reader.
  def initialize(@io : IO, @sync_close : Bool = false)
    @buf = uninitialized UInt8[1] # input buffer used by xz
    @stream = LZMA::Stream.new
    alloc = LZMA::Allocator.new
    alloc.alloc = LZMA::AllocFunc.new { |_, items, size| GC.malloc(items * size) }
    alloc.free = LZMA::FreeFunc.new { |_, address| GC.free(address) }

    @stream.allocator = pointerof(alloc)
    ret = LZMA.stream_decoder(pointerof(@stream), Int64::MAX, LZMA_CONCATENATED)
    raise DecompressionError.new(ret) unless ret.ok?

    @peek = nil
    @end = false
  end

  # Creates a new reader from the given *io*, yields it to the given block,
  # and closes it at its end.
  def self.open(io : IO, sync_close : Bool = false)
    reader = new(io, sync_close: sync_close)
    yield reader ensure reader.close
  end

  # Creates a new reader from the given *filename*.
  def self.new(filename : String)
    new(::File.new(filename), sync_close: true)
  end

  # Creates a new reader from the given *io*, yields it to the given block,
  # and closes it at the end.
  def self.open(io : IO, sync_close = false)
    reader = new(io, sync_close: sync_close)
    yield reader ensure reader.close
  end

  # Creates a new reader from the given *filename*, yields it to the given block,
  # and closes it at the end.
  def self.open(filename : String)
    reader = new(filename)
    yield reader ensure reader.close
  end

  # Always raises `IO::Error` because this is a read-only `IO`.
  def unbuffered_write(slice : Bytes)
    raise IO::Error.new "Can't write to XZ::Reader"
  end

  def unbuffered_read(slice : Bytes)
    check_open

    return 0 if slice.empty? || @end

    @stream.next_out = slice.to_unsafe
    @stream.avail_out = slice.size

    loop do
      action = LZMA::Action::Run
      if @stream.avail_in == 0
        # Try to peek into the underlying IO, so we can feed more data into xz
        @peek = @io.peek
        if peek = @peek
          @stream.next_in = peek
          @stream.avail_in = peek.size
        else
          # If peeking is not possible, we read byte per byte
          @stream.next_in = @buf.to_unsafe
          @stream.avail_in = @io.read(@buf.to_slice).to_u32
        end
        action = LZMA::Action::Finish if @stream.avail_in == 0
      end
      old_avail_in = @stream.avail_in

      ret = LZMA.code(pointerof(@stream), action)
      @end = ret.stream_end?
      read_bytes = slice.size - @stream.avail_out
      # If we were able to peek, skip the used bytes in the underlying IO
      avail_in_diff = old_avail_in - @stream.avail_in
      @io.skip(avail_in_diff) if @peek && avail_in_diff > 0

      if @stream.avail_out == 0 || ret.stream_end?
        size = slice.size - @stream.avail_out
        return size
      end
      raise DecompressionError.new(ret) unless ret.ok?
      # nothing got written to slice because decompressor need more input. We are here because
      # we haven't reached StreamEnd
      if read_bytes == 0
        next
      else
        return read_bytes
      end
    end
  end

  def unbuffered_flush
    raise IO::Error.new "Can't flush XZ::Reader"
  end

  # Closes this reader.
  def unbuffered_close
    return if @closed
    @closed = true

    LZMA._end(pointerof(@stream))

    @io.close if @sync_close
  end

  def unbuffered_rewind
    check_open

    @io.rewind

    initialize(@io, @sync_close)
  end

  # :nodoc:
  def inspect(io : IO) : Nil
    to_s(io)
  end
end
