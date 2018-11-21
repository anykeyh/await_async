# Lightweight Future structure.
class MiniFuture(T)
  class TimeoutException < Exception
  end

  @status = :running
  @channel = Channel(T).new(1)
  @error : Exception?
  @output : T?

  def initialize(immediate = true, &block : -> T)
    spawn do
      begin
        @channel.send block.call
      rescue ex
        @error = ex
      ensure
        @status = :terminated
      end
    end

    Fiber.yield if immediate
  end

  def running?
    @status == :running
  end

  def finished?
    !running?
  end

  def error?
    @error
  end

  def await(timeout : Time::Span? = nil)
    if @status != :flushed
      if timeout
        timeout_channel = Channel(Nil).new

        spawn do
          sleep timeout.not_nil!
          timeout_channel.send nil unless @status == :flushed
        end

        select
        when timeout_channel.receive
          raise TimeoutException.new
        when @output = @channel.receive
          @status = :flushed
        end
      else
        @status = :flushed
        @output = @channel.receive
      end
    end

    if ex = @error
      raise ex
    end

    {% if T.nilable? %}
      @output
    {% else %}
      @output.not_nil!
    {% end %}
  end
end
