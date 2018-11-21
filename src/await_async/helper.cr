require "./mini_future"

module AwaitAsync::Helper
  extend self

  # Await a future to resolve.
  def await(future : MiniFuture)
    future.await
  end

  # Await a future to resolve, or throw `MiniFuture::TimeoutException`
  # otherwise.
  def await(timeout : Time::Span, future : MiniFuture)
    future.await(timeout)
  end

  # Iterate through all the future and await for them.
  def await(futures : Enumerable(MiniFuture(T))) forall T
    futures.map(&.await)
  end

  # Iterate through all the future and await for them.
  def await(timeout : Time::Span, futures : Enumerable(MiniFuture(T))) forall T
    futures.map(&.await(timeout))
  end

  # Ask Crystal to run this method asynchronously in its own fiber.
  macro async!(method)
    MiniFuture(typeof({{method}})).new { {{method}} }
  end

  # Ask Crystal to run this method asynchronously in its own fiber.
  #
  # NOTE: The fiber won't be started after creation.
  macro async(method)
    MiniFuture(typeof({{method}})).new(immediate: false) { {{method}} }
  end

  macro async!(&block)
    %lmb = -> { {{block.body}} }
    MiniFuture(typeof(%lmb.call)).new { %lmb.call }
  end

  macro async(&block)
    %lmb = -> { {{block.body}} }
    MiniFuture(typeof(%lmb.call)).new(immediate: false) { %lmb.call }
  end
end
