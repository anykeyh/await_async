require "benchmark"
require "file_utils"
require "../src/await_async"

FileUtils.rm_rf "generated"
FileUtils.mkdir "generated"

def multiple_small_write
  2048.times do |i|
    File.write("generated/#{i}", i.to_s)
  end
end

def multiple_small_write_async
  2048.times.map do |i|
    async! File.write("generated/#{i}", i.to_s)
  end
end

puts "With synchronous call:"
puts Benchmark.measure { multiple_small_write }

FileUtils.rm_rf "generated/*"

puts "With asynchronous call:"
puts Benchmark.measure { await multiple_small_write_async }
