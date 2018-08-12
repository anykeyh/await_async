## Await / Async

Add `await` and `async` keyword in Crystal.

## Installation

In your `shards.yml`:

```crystal
dependencies:
  await_async:
    github: anykeyh/await_async
    branch: master
```

Then:

```crystal
require "await_async"

x = async fetch_something

do_some_computation_now

await x
```

## Usage

- Call `async` on any method or block to create a MiniFuture
- Call `await` on any MiniFuture to wait for/get the result
- Conveniently, you can call `await` on future's array.

Can improve drastically application which relay on blocking IO like web API
or file writing.

### await(timeout, future)

```crystal
f = async check_website

begin
  await 5.seconds, f
rescue MiniFuture::TimeoutException
  # rescue from timeout
end
```

### async_lp

By default, async call the newly created fiber just after creation.

- You can use instead `async_lp` so the fiber won't start now:

```crystal
f = async{ 1 + 2 }
# At this moment the result is already computed
# f.finished? == true
await f # return 3

#vs

f = async_lp{ 1 + 2 }
# Here the result is not computed
# f.finished? == false
await f #Compute now
```

Usually, use `async_lp` if your block is computation intensive and current thread
has IO blocking operation. Use `async` in other cases.

In case of errors, the exception will be raise at `await` moment, in the await
thread.

## MiniFuture

A minimalist version of future. Has `finished?` and `running?` methods.

I don't use Crystal's `Concurrent::Future` class because `:nodoc:`

## Why?

Because crystal is great for building CLI tools. And CLI deals a lot with
files and sockets. And IO performed in main thread are slow.

Usage of Channel is recommended for complex software, as it offers more patterns.

`await/async` is useful to build fast and deliver fast.

## I don't want await/async to be exported in the global scope

1. require `await_async/helper` instead of `await_async`
2. In the class/module you want to use the methods, add `include AwaitAsync::Helper`.
   You can also simply call `await/async` directly from `AwaitAsync::Helper`

## Example

```crystal

def fetch_websites_async
  %w(www.github.com
  www.yahoo.com
  www.facebook.com
  www.twitter.com
  crystal-lang.org).map do |ws|
    async do
      HTTP::Client.get "https://#{ws}"
    end
  end
end

# Process the websites concurrently. Start querying another website when the
# first one is waiting for response
await(5.seconds, fetch_websites_async).each do |response|
 #...
end
```

## Licence

MIT