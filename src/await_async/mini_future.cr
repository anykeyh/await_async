# Lightweight Future structure.
class MiniFuture(T)
  class TimeoutException < Exception
  end

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
    !running?
  end

  def running?
    @status == :running
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