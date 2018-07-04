# Lightweight Future structure.
class MiniFuture(T)
  @status = :running
  @channel = Channel(T).new(1)
  @error : Exception? = nil
  @output : T?

  def initialize(prioritary = true, &block : -> T)
    spawn do
      begin
        @channel.send block.call
      rescue e
        @error = e
      ensure
        @status = :terminated
      end
    end

    Fiber.yield if prioritary
  end

  def error?
    @error.any?
  end

  def finished?
    @status == :terminated
  end

  def running?
    @status == :running
  end

  def await
    @output = @channel.receive
    @status = :terminated

    if e = @error
      raise e
    end

    {% if T.nilable? %}
      @output
    {% else %}
      @output.not_nil!
    {% end %}
  end
end

def await(future : MiniFuture)
  future.await
end

def await(futures : Iterator(MiniFuture(T))) forall T
  futures.map { |x| await x }
end

macro async(method)
  MiniFuture(typeof({{method}})).new{ {{method}} }
end

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
