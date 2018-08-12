require "spec"
require "../src/await_async"

module AwaitAsyncSpec
  extend self

  @@string_output = ""

  def a_long_method
    string_output = "A"
    sleep(0.1)
    string_output += "B"
  end

  describe "Await/Async" do
    it "works with method" do
      x = async a_long_method

      (await x).should eq "AB"
    end

    it "works with block" do
      @@string_output = ""

      x = async { @@string_output = "B" }

      @@string_output.should eq "B"
    end

    it "works with array" do
      o = 3.times.map { |x| async { 1 + x } }
      await(o).to_a.should eq [1, 2, 3]
    end

    it "can check finished? method" do
      @@string_output = ""

      x = async { sleep(0.1); @@string_output = "B" }
      x.finished?.should eq false
      x.running?.should eq true
      await x
      x.finished?.should eq true
      x.running?.should eq false

      x = async { sleep(0.1); @@string_output = "B" }
      sleep 0.15 # < Should give time to run the fiber.
      x.finished?.should eq true
      x.running?.should eq false
    end

    it "offers low priority async" do
      async { 1 + 1 }.finished?.should eq true
      async_lp { 1 + 1 }.finished?.should eq false
    end

    it "can call multiple time await" do
      f = async { 1 + 1 }
      await f
      await f
    end

    it "can await with timeout" do
      x = async { sleep 0.5 }

      expect_raises MiniFuture::TimeoutException do
        await 0.2.seconds, x
      end

      x = async { sleep 0.1 }
      await 0.2.seconds, x # < Should not raise exception
    end
  end

  it "can await with timeout (array)" do
    x = 5.times.map { |arr| async { sleep 0.5 } }.to_a

    expect_raises MiniFuture::TimeoutException do
      await 0.2.seconds, x
    end

    x = 5.times.map { async { sleep 0.1 } }.to_a
    await 0.2.seconds, x # < Should not raise exception
  end
end
