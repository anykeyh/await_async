require "./spec_helper"

def long_running_method
  sleep 0.1
  "FOO"
end

describe AwaitAsync::Helper do
  it "works with method" do
    x = async! long_running_method
    (await x).should eq "FOO"
  end

  it "works with block" do
    x = async! { "FOO" }
    (await x).should eq "FOO"
  end

  it "works with array" do
    arr = 3.times.map { |x| async! { 1 + x } }
    await(arr).to_a.should eq [1, 2, 3]
  end

  it "can check finished? method" do
    x = async! {
      sleep 0.1
      "FOO"
    }
    x.finished?.should be_false
    x.running?.should be_true

    (await x).should eq "FOO"
    x.finished?.should be_true
    x.running?.should be_false

    x = async! {
      sleep 0.1
      :BAR
    }
    sleep 0.15 # < Should give time to run the fiber.

    (await x).should eq :BAR
    x.finished?.should be_true
    x.running?.should be_false
  end

  it "offers low priority async" do
    async! { 1 + 1 }.finished?.should be_true
    async { 1 + 1 }.finished?.should be_false
  end

  it "can call multiple time await" do
    f = async! { 1 + 1 }
    await f
    await f
  end

  it "can await with timeout" do
    x = async! { sleep 0.5 }

    expect_raises MiniFuture::TimeoutException do
      await 0.2.seconds, x
    end

    x = async! { sleep 0.1 }
    await 0.2.seconds, x # < Should not raise exception
  end

  it "can await with timeout (array)" do
    x = 5.times.map { async! { sleep 0.5 } }.to_a

    expect_raises MiniFuture::TimeoutException do
      await 0.2.seconds, x
    end

    x = 5.times.map { async! { sleep 0.1 } }.to_a
    await 0.2.seconds, x # < Should not raise exception
  end
end
