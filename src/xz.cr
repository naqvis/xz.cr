# XZ Crystal Wrapper
require "semantic_version"

module XZ
  VERSION = "0.1.1"

  LZMA_VERSION         = SemanticVersion.parse String.new(LZMA.version_string)
  LZMA_VERSION_MINIMUM = SemanticVersion.parse("5.2.4")
  raise "unsupported lzma version #{LZMA_VERSION}, needs #{LZMA_VERSION_MINIMUM} or higher" unless LZMA_VERSION >= LZMA_VERSION_MINIMUM

  module PRESET
    NO_COMPRESSION      = 0
    BEST_SPEED          = 1
    BEST_COMPRESSION    = 9
    DEFAULT_COMPRESSION = 6
  end

  class CompressionError < Exception
    def initialize(ret : LZMA::Ret)
      msg = case ret
            when .options_error?     then "Specific preset is not supported"
            when .mem_error?         then "Memory allocation failed"
            when .data_error?        then "File size limits exceeded"
            when .unsupported_check? then "Specified integrity check not supported"
            else
              "Unknown error #{ret}, possible a bug"
            end
      super("XZ::Writer: #{msg}")
    end
  end

  class DecompressionError < Exception
    def initialize(ret : LZMA::Ret)
      msg = case ret
            when .options_error? then "Unsupported compression options"
            when .mem_error?     then "Memory allocation failed"
            when .format_error?  then "File format not recognized. The input is not in the .xz format"
            when .data_error?    then "Compressed file is corrupt"
            when .buf_error?     then "Compressed file is truncated or otherwise corrupt"
            else
              "Unknown error #{ret}, possible a bug"
            end
      super("XZ::Reader: #{msg}")
    end
  end
end

require "./xz/*"
