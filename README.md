## Await / Async

Add `await` and `async` keyword in Crystal.


## Usage

- Call `async` on any method or block to create a MiniFuture
- Call `await` on any MiniFuture to wait for/get the result
- Conveniently, you can call await on iterators (eg. Array) .

Can improve drastically application which relay on blocking IO like web API
or file writing.

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

In case of errors, the exception will be raise at `await` moment.

## MiniFuture

A minimalist version of future. Has `finished?` and `running?` methods.

I don't use Crystal's `Concurrent::Future` class because `:nodoc:`

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
await(fetch_websites_async).each do |response|
 #...
end
```

## Licence

MIT.