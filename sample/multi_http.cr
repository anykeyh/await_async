require "http/client"
require "benchmark"
require "../src/await_async"

WEBSITES = %w(www.github.com
  www.yahoo.com
  www.facebook.com
  www.twitter.com
  crystal-lang.org)

def fetch_websites_async
  WEBSITES.map do |ws|
    async do
      HTTP::Client.get "https://#{ws}"
    end
  end
end

def fetch_websites
  WEBSITES.map do |ws|
    HTTP::Client.get "https://#{ws}"
  end
end

puts "With synchronous call: "
puts Benchmark.measure { fetch_websites }

puts "With asynchronous call: "
puts Benchmark.measure { await fetch_websites_async }
