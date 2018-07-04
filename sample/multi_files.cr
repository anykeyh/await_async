require "benchmark"
require "../src/await_async"

`mkdir generated`
`rm -r generated/*`

def multiple_small_write
  2048.times do |x|
    File.write("generated/#{x}", "#{x}")
  end
end

def multiple_small_write_async
  2048.times.map do |x|
    async File.write("generated/#{x}", "#{x}")
  end
end

puts "With synchronous call: "
puts Benchmark.measure { multiple_small_write }

`rm -r generated/*`

puts "With asynchronous call: "
puts Benchmark.measure { await multiple_small_write_async }
