require "./spec_helper"
require "file_utils"
describe XZ do
  it "Test Round Trip" do
    compressed_io = IO::Memory.new
    str = "The quick brown fox jumps over the lazy dog."
    XZ::Writer.open(compressed_io) do |zw|
      zw.write str.to_slice
    end
    compressed_io.rewind
    uncompressed = XZ::Reader.open(compressed_io) do |zr|
      zr.gets_to_end
    end
    uncompressed.should eq(str)
  end

  it "Test write/Read file" do
    File.open("./LICENSE", "r") do |input_file|
      File.open("./LICENSE.xz", "w") do |output_file|
        XZ::Writer.open(output_file) do |xz|
          IO.copy(input_file, xz)
        end
      end
    end
    expected = File.read("./LICENSE")
    got = File.open("./LICENSE.xz") do |file|
      XZ::Reader.open(file) do |xz|
        xz.gets_to_end
      end
    end
    got.should eq(expected)
    FileUtils.rm("./LICENSE.xz")
  end
end
