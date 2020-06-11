module Compress::XZ
  @[Link(ldflags: "`command -v pkg-config > /dev/null && pkg-config --libs liblzma 2> /dev/null|| printf %s '--llzma'`")]
  lib LZMA
    alias Uint8T = UInt8
    alias Uint32T = LibC::UInt
    alias Uint64T = LibC::ULong
    alias Vli = Uint64T
    alias Bool = UInt8

    H_INTERNAL               =    1
    VERSION_MAJOR            =    5
    VERSION_MINOR            =    2
    VERSION_PATCH            =    4
    VERSION_STABILITY_ALPHA  =    0
    VERSION_STABILITY_BETA   =    1
    VERSION_STABILITY_STABLE =    2
    VLI_BYTES_MAX            =    9
    CHECK_ID_MAX             =   15
    CHECK_SIZE_MAX           =   64
    FILTERS_MAX              =    4
    DELTA_DIST_MIN           =    1
    DELTA_DIST_MAX           =  256
    LCLP_MIN                 =    0
    LCLP_MAX                 =    4
    LC_DEFAULT               =    3
    LP_DEFAULT               =    0
    PB_MIN                   =    0
    PB_MAX                   =    4
    PB_DEFAULT               =    2
    STREAM_HEADER_SIZE       =   12
    BACKWARD_SIZE_MIN        =    4
    BLOCK_HEADER_SIZE_MIN    =    8
    BLOCK_HEADER_SIZE_MAX    = 1024

    fun version_number = lzma_version_number : Uint32T
    fun version_string = lzma_version_string : LibC::Char*

    fun code = lzma_code(strm : Stream*, action : Action) : Ret

    struct Stream
      next_in : Uint8T*
      avail_in : LibC::SizeT
      total_in : Uint64T
      next_out : Uint8T*
      avail_out : LibC::SizeT
      total_out : Uint64T
      allocator : Allocator*
      internal : Void*
      reserved_ptr1 : Void*
      reserved_ptr2 : Void*
      reserved_ptr3 : Void*
      reserved_ptr4 : Void*
      reserved_int1 : Uint64T
      reserved_int2 : Uint64T
      reserved_int3 : LibC::SizeT
      reserved_int4 : LibC::SizeT
      reserved_enum1 : ReservedEnum
      reserved_enum2 : ReservedEnum
    end

    alias AllocFunc = Void*, LibC::SizeT, LibC::SizeT -> Void*
    alias FreeFunc = (Void*, Void*) ->

    struct Allocator
      alloc : AllocFunc
      free : FreeFunc
      opaque : Void*
    end

    enum ReservedEnum
      ReservedEnum = 0
    end
    enum Action : Int64
      Run         = 0
      SyncFlush   = 1
      FullFlush   = 2
      FullBarrier = 4
      Finish      = 3
    end
    enum Ret : Int64
      Ok               =  0
      StreamEnd        =  1
      NoCheck          =  2
      UnsupportedCheck =  3
      GetCheck         =  4
      MemError         =  5
      MemlimitError    =  6
      FormatError      =  7
      OptionsError     =  8
      DataError        =  9
      BufError         = 10
      ProgError        = 11
    end
    fun _end = lzma_end(strm : Stream*)
    fun get_progress = lzma_get_progress(strm : Stream*, progress_in : Uint64T*, progress_out : Uint64T*)
    fun memusage = lzma_memusage(strm : Stream*) : Uint64T
    fun memlimit_get = lzma_memlimit_get(strm : Stream*) : Uint64T
    fun memlimit_set = lzma_memlimit_set(strm : Stream*, memlimit : Uint64T) : Ret
    fun vli_encode = lzma_vli_encode(vli : Vli, vli_pos : LibC::SizeT*, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun vli_decode = lzma_vli_decode(vli : Vli*, vli_pos : LibC::SizeT*, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT) : Ret
    fun vli_size = lzma_vli_size(vli : Vli) : Uint32T

    fun check_is_supported = lzma_check_is_supported(check : Check) : Bool
    enum Check : Int64
      CheckNone   =  0
      CheckCrc32  =  1
      CheckCrc64  =  4
      CheckSha256 = 10
    end

    fun check_size = lzma_check_size(check : Check) : Uint32T
    fun crc32 = lzma_crc32(buf : Uint8T*, size : LibC::SizeT, crc : Uint32T) : Uint32T
    fun crc64 = lzma_crc64(buf : Uint8T*, size : LibC::SizeT, crc : Uint64T) : Uint64T
    fun get_check = lzma_get_check(strm : Stream*) : Check
    fun filter_encoder_is_supported = lzma_filter_encoder_is_supported(id : Vli) : Bool
    fun filter_decoder_is_supported = lzma_filter_decoder_is_supported(id : Vli) : Bool
    fun filters_copy = lzma_filters_copy(src : Filter*, dest : Filter*, allocator : Allocator*) : Ret

    struct Filter
      id : Vli
      options : Void*
    end

    fun raw_encoder_memusage = lzma_raw_encoder_memusage(filters : Filter*) : Uint64T
    fun raw_decoder_memusage = lzma_raw_decoder_memusage(filters : Filter*) : Uint64T
    fun raw_encoder = lzma_raw_encoder(strm : Stream*, filters : Filter*) : Ret
    fun raw_decoder = lzma_raw_decoder(strm : Stream*, filters : Filter*) : Ret
    fun filters_update = lzma_filters_update(strm : Stream*, filters : Filter*) : Ret
    fun raw_buffer_encode = lzma_raw_buffer_encode(filters : Filter*, allocator : Allocator*, in : Uint8T*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun raw_buffer_decode = lzma_raw_buffer_decode(filters : Filter*, allocator : Allocator*, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun properties_size = lzma_properties_size(size : Uint32T*, filter : Filter*) : Ret
    fun properties_encode = lzma_properties_encode(filter : Filter*, props : Uint8T*) : Ret
    fun properties_decode = lzma_properties_decode(filter : Filter*, allocator : Allocator*, props : Uint8T*, props_size : LibC::SizeT) : Ret
    fun filter_flags_size = lzma_filter_flags_size(size : Uint32T*, filter : Filter*) : Ret
    fun filter_flags_encode = lzma_filter_flags_encode(filter : Filter*, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun filter_flags_decode = lzma_filter_flags_decode(filter : Filter*, allocator : Allocator*, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT) : Ret

    fun mf_is_supported = lzma_mf_is_supported(match_finder : MatchFinder) : Bool
    enum MatchFinder : Int64
      MfHc3 =  3
      MfHc4 =  4
      MfBt2 = 18
      MfBt3 = 19
      MfBt4 = 20
    end

    fun mode_is_supported = lzma_mode_is_supported(mode : Mode) : Bool
    enum Mode : Int64
      ModeFast   = 1
      ModeNormal = 2
    end
    fun preset = lzma_lzma_preset(options : OptionsLzma*, preset : Uint32T) : Bool

    struct OptionsLzma
      dict_size : Uint32T
      preset_dict : Uint8T*
      preset_dict_size : Uint32T
      lc : Uint32T
      lp : Uint32T
      pb : Uint32T
      mode : Mode
      nice_len : Uint32T
      mf : MatchFinder
      depth : Uint32T
      reserved_int1 : Uint32T
      reserved_int2 : Uint32T
      reserved_int3 : Uint32T
      reserved_int4 : Uint32T
      reserved_int5 : Uint32T
      reserved_int6 : Uint32T
      reserved_int7 : Uint32T
      reserved_int8 : Uint32T
      reserved_enum1 : ReservedEnum
      reserved_enum2 : ReservedEnum
      reserved_enum3 : ReservedEnum
      reserved_enum4 : ReservedEnum
      reserved_ptr1 : Void*
      reserved_ptr2 : Void*
    end

    fun easy_encoder_memusage = lzma_easy_encoder_memusage(preset : Uint32T) : Uint64T
    fun easy_decoder_memusage = lzma_easy_decoder_memusage(preset : Uint32T) : Uint64T
    fun easy_encoder = lzma_easy_encoder(strm : Stream*, preset : Uint32T, check : Check) : Ret
    fun easy_buffer_encode = lzma_easy_buffer_encode(preset : Uint32T, check : Check, allocator : Allocator*, in : Uint8T*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun stream_encoder = lzma_stream_encoder(strm : Stream*, filters : Filter*, check : Check) : Ret
    fun stream_encoder_mt_memusage = lzma_stream_encoder_mt_memusage(options : Mt*) : Uint64T

    struct Mt
      flags : Uint32T
      threads : Uint32T
      block_size : Uint64T
      timeout : Uint32T
      preset : Uint32T
      filters : Filter*
      check : Check
      reserved_enum1 : ReservedEnum
      reserved_enum2 : ReservedEnum
      reserved_enum3 : ReservedEnum
      reserved_int1 : Uint32T
      reserved_int2 : Uint32T
      reserved_int3 : Uint32T
      reserved_int4 : Uint32T
      reserved_int5 : Uint64T
      reserved_int6 : Uint64T
      reserved_int7 : Uint64T
      reserved_int8 : Uint64T
      reserved_ptr1 : Void*
      reserved_ptr2 : Void*
      reserved_ptr3 : Void*
      reserved_ptr4 : Void*
    end

    fun stream_encoder_mt = lzma_stream_encoder_mt(strm : Stream*, options : Mt*) : Ret
    fun alone_encoder = lzma_alone_encoder(strm : Stream*, options : OptionsLzma*) : Ret
    fun stream_buffer_bound = lzma_stream_buffer_bound(uncompressed_size : LibC::SizeT) : LibC::SizeT
    fun stream_buffer_encode = lzma_stream_buffer_encode(filters : Filter*, check : Check, allocator : Allocator*, in : Uint8T*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun stream_decoder = lzma_stream_decoder(strm : Stream*, memlimit : Uint64T, flags : Uint32T) : Ret
    fun auto_decoder = lzma_auto_decoder(strm : Stream*, memlimit : Uint64T, flags : Uint32T) : Ret
    fun alone_decoder = lzma_alone_decoder(strm : Stream*, memlimit : Uint64T) : Ret
    fun stream_buffer_decode = lzma_stream_buffer_decode(memlimit : Uint64T*, flags : Uint32T, allocator : Allocator*, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun stream_header_encode = lzma_stream_header_encode(options : StreamFlags*, out : Uint8T*) : Ret

    struct StreamFlags
      version : Uint32T
      backward_size : Vli
      check : Check
      reserved_enum1 : ReservedEnum
      reserved_enum2 : ReservedEnum
      reserved_enum3 : ReservedEnum
      reserved_enum4 : ReservedEnum
      reserved_bool1 : Bool
      reserved_bool2 : Bool
      reserved_bool3 : Bool
      reserved_bool4 : Bool
      reserved_bool5 : Bool
      reserved_bool6 : Bool
      reserved_bool7 : Bool
      reserved_bool8 : Bool
      reserved_int1 : Uint32T
      reserved_int2 : Uint32T
    end

    fun stream_footer_encode = lzma_stream_footer_encode(options : StreamFlags*, out : Uint8T*) : Ret
    fun stream_header_decode = lzma_stream_header_decode(options : StreamFlags*, in : Uint8T*) : Ret
    fun stream_footer_decode = lzma_stream_footer_decode(options : StreamFlags*, in : Uint8T*) : Ret
    fun stream_flags_compare = lzma_stream_flags_compare(a : StreamFlags*, b : StreamFlags*) : Ret
    fun block_header_size = lzma_block_header_size(block : Block*) : Ret

    struct Block
      version : Uint32T
      header_size : Uint32T
      check : Check
      compressed_size : Vli
      uncompressed_size : Vli
      filters : Filter*
      raw_check : Uint8T[64]
      reserved_ptr1 : Void*
      reserved_ptr2 : Void*
      reserved_ptr3 : Void*
      reserved_int1 : Uint32T
      reserved_int2 : Uint32T
      reserved_int3 : Vli
      reserved_int4 : Vli
      reserved_int5 : Vli
      reserved_int6 : Vli
      reserved_int7 : Vli
      reserved_int8 : Vli
      reserved_enum1 : ReservedEnum
      reserved_enum2 : ReservedEnum
      reserved_enum3 : ReservedEnum
      reserved_enum4 : ReservedEnum
      ignore_check : Bool
      reserved_bool2 : Bool
      reserved_bool3 : Bool
      reserved_bool4 : Bool
      reserved_bool5 : Bool
      reserved_bool6 : Bool
      reserved_bool7 : Bool
      reserved_bool8 : Bool
    end

    fun block_header_encode = lzma_block_header_encode(block : Block*, out : Uint8T*) : Ret
    fun block_header_decode = lzma_block_header_decode(block : Block*, allocator : Allocator*, in : Uint8T*) : Ret
    fun block_compressed_size = lzma_block_compressed_size(block : Block*, unpadded_size : Vli) : Ret
    fun block_unpadded_size = lzma_block_unpadded_size(block : Block*) : Vli
    fun block_total_size = lzma_block_total_size(block : Block*) : Vli
    fun block_encoder = lzma_block_encoder(strm : Stream*, block : Block*) : Ret
    fun block_decoder = lzma_block_decoder(strm : Stream*, block : Block*) : Ret
    fun block_buffer_bound = lzma_block_buffer_bound(uncompressed_size : LibC::SizeT) : LibC::SizeT
    fun block_buffer_encode = lzma_block_buffer_encode(block : Block*, allocator : Allocator*, in : Uint8T*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun block_uncomp_encode = lzma_block_uncomp_encode(block : Block*, in : Uint8T*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun block_buffer_decode = lzma_block_buffer_decode(block : Block*, allocator : Allocator*, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret

    fun index_memusage = lzma_index_memusage(streams : Vli, blocks : Vli) : Uint64T
    fun index_memused = lzma_index_memused(i : Index) : Uint64T
    type Index = Void*
    fun index_init = lzma_index_init(allocator : Allocator*) : Index
    fun index_end = lzma_index_end(i : Index, allocator : Allocator*)
    fun index_append = lzma_index_append(i : Index, allocator : Allocator*, unpadded_size : Vli, uncompressed_size : Vli) : Ret
    fun index_stream_flags = lzma_index_stream_flags(i : Index, stream_flags : StreamFlags*) : Ret
    fun index_checks = lzma_index_checks(i : Index) : Uint32T
    fun index_stream_padding = lzma_index_stream_padding(i : Index, stream_padding : Vli) : Ret
    fun index_stream_count = lzma_index_stream_count(i : Index) : Vli
    fun index_block_count = lzma_index_block_count(i : Index) : Vli
    fun index_size = lzma_index_size(i : Index) : Vli
    fun index_stream_size = lzma_index_stream_size(i : Index) : Vli
    fun index_total_size = lzma_index_total_size(i : Index) : Vli
    fun index_file_size = lzma_index_file_size(i : Index) : Vli
    fun index_uncompressed_size = lzma_index_uncompressed_size(i : Index) : Vli
    fun index_iter_init = lzma_index_iter_init(iter : IndexIter*, i : Index)

    struct IndexIter
      stream : IndexIterStream
      block : IndexIterBlock
      internal : IndexIterInternal[6]
    end

    struct IndexIterStream
      flags : StreamFlags*
      reserved_ptr1 : Void*
      reserved_ptr2 : Void*
      reserved_ptr3 : Void*
      number : Vli
      block_count : Vli
      compressed_offset : Vli
      uncompressed_offset : Vli
      compressed_size : Vli
      uncompressed_size : Vli
      padding : Vli
      reserved_vli1 : Vli
      reserved_vli2 : Vli
      reserved_vli3 : Vli
      reserved_vli4 : Vli
    end

    struct IndexIterBlock
      number_in_file : Vli
      compressed_file_offset : Vli
      uncompressed_file_offset : Vli
      number_in_stream : Vli
      compressed_stream_offset : Vli
      uncompressed_stream_offset : Vli
      uncompressed_size : Vli
      unpadded_size : Vli
      total_size : Vli
      reserved_vli1 : Vli
      reserved_vli2 : Vli
      reserved_vli3 : Vli
      reserved_vli4 : Vli
      reserved_ptr1 : Void*
      reserved_ptr2 : Void*
      reserved_ptr3 : Void*
      reserved_ptr4 : Void*
    end

    union IndexIterInternal
      p : Void*
      s : LibC::SizeT
      v : Vli
    end

    fun index_iter_rewind = lzma_index_iter_rewind(iter : IndexIter*)
    fun index_iter_next = lzma_index_iter_next(iter : IndexIter*, mode : IndexIterMode) : Bool
    enum IndexIterMode : Int64
      IndexIterAny           = 0
      IndexIterStream        = 1
      IndexIterBlock         = 2
      IndexIterNonemptyBlock = 3
    end
    fun index_iter_locate = lzma_index_iter_locate(iter : IndexIter*, target : Vli) : Bool
    fun index_cat = lzma_index_cat(dest : Index, src : Index, allocator : Allocator*) : Ret
    fun index_dup = lzma_index_dup(i : Index, allocator : Allocator*) : Index
    fun index_encoder = lzma_index_encoder(strm : Stream*, i : Index) : Ret
    fun index_decoder = lzma_index_decoder(strm : Stream*, i : Index*, memlimit : Uint64T) : Ret
    fun index_buffer_encode = lzma_index_buffer_encode(i : Index, out : Uint8T*, out_pos : LibC::SizeT*, out_size : LibC::SizeT) : Ret
    fun index_buffer_decode = lzma_index_buffer_decode(i : Index*, memlimit : Uint64T*, allocator : Allocator*, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT) : Ret
    fun index_hash_init = lzma_index_hash_init(index_hash : IndexHash, allocator : Allocator*) : IndexHash
    type IndexHash = Void*
    fun index_hash_end = lzma_index_hash_end(index_hash : IndexHash, allocator : Allocator*)
    fun index_hash_append = lzma_index_hash_append(index_hash : IndexHash, unpadded_size : Vli, uncompressed_size : Vli) : Ret
    fun index_hash_decode = lzma_index_hash_decode(index_hash : IndexHash, in : Uint8T*, in_pos : LibC::SizeT*, in_size : LibC::SizeT) : Ret
    fun index_hash_size = lzma_index_hash_size(index_hash : IndexHash) : Vli
    fun physmem = lzma_physmem : Uint64T
    fun cputhreads = lzma_cputhreads : Uint32T
  end
end
