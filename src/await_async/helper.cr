require "./mini_future"

module AwaitAsync::Helper
  extend self

  # Await a future to resolve, then print the result
  # of the method
  def await(future : MiniFuture)
    future.await
  end

  # Await a future to resolve, until a specified amount of time
  # print the result of the method, or throw MiniFuture::TimeoutException
  # otherwise
  def await(timeout : Time::Span, future : MiniFuture)
    future.await(timeout)
  end

  # Iterate through all the future and await for them.
  # Print the results as an array of result.
  def await(futures : Iterator(MiniFuture(T)) | Array(MiniFuture(T))) forall T
    futures.map(&.await)
  end

  # Iterate through all the future and await for them.
  # Print the results as an array of result.
  def await(timeout : Time::Span, futures : Iterator(MiniFuture(T)) | Array(MiniFuture(T))) forall T
    futures.map(&.await(timeout))
  end

  # Ask Crystal to run this method asynchronously in its own fiber
  macro async(method)
    MiniFuture(typeof({{method}})).new{ {{method}} }
  end

  # Ask Crystal to run this method asynchronously in its own fiber.
  # lp stands for low priorty, meaning the fiber won't be started after creation
  macro async_lp(method)
    MiniFuture(typeof({{method}})).new(prioritary: false){ {{method}} }
  end

  macro async(&block)
    %lmb = -> { {{block.body}} }
    MiniFuture( typeof(%lmb.call) ).new{ %lmb.call }
  end

  macro async_lp(&block)
    %lmb = -> { {{block.body}} }
    MiniFuture( typeof(%lmb.call) ).new(prioritary: false){ %lmb.call }
  end
end