require "benchmark"
require "http/client"
require "../src/await_async"

WEBSITES = %w[
  www.github.com
  www.yahoo.com
  www.facebook.com
  www.twitter.com
  crystal-lang.org
]

def fetch_websites
  WEBSITES.map do |url|
    HTTP::Client.get "https://#{url}"
  end
end

def fetch_websites_async
  WEBSITES.map do |url|
    async! do
      HTTP::Client.get "https://#{url}"
    end
  end
end

puts "With synchronous call:"
puts Benchmark.measure { fetch_websites }

puts "With asynchronous call:"
puts Benchmark.measure { await fetch_websites_async }
