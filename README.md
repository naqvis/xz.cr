# Crystal XZ

Crystal bindings to the XZ (lzma) compression library.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     xz:
       github: naqvis/xz.cr
   ```

2. Run `shards install`

## Usage

```crystal
require "xz"
```

`XZ` shard provides both `Compress::XZ::Reader` and `Compress::XZ::Writer`.

## Example: decompress an xz file
#
```crystal
require "xz"

string = File.open("file.xz") do |file|
   Compress::XZ::Reader.open(file) do |xz|
     xz.gets_to_end
   end
end
pp string
```

## Example: compress to xz compression format
#
```crystal
require "xz"

File.write("file.txt", "abcd")

File.open("./file.txt", "r") do |input_file|
  File.open("./file.xz", "w") do |output_file|
    Compress::XZ::Writer.open(output_file) do |xz|
      IO.copy(input_file, xz)
    end
  end
end
```

## Contributing

1. Fork it (<https://github.com/naqvis/xz.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ali Naqvi](https://github.com/naqvis) - creator and maintainer
