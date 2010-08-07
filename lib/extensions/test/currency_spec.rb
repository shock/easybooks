require 'spec/autorun'
require 'spec/runner/formatter/text_mate_formatter'
require File.dirname(__FILE__) + '/../currency'

describe Currency do
  it "defaults to zero on creation" do
    c = Currency.new
    c.should == 0
  end
  
  it "initializes from a floating point number" do
    c = Currency.new(3.33)
  end
  
  it "initializes from a string" do
    c = Currency.new('3.33')
    c.value.should == 333
  end
  
  it "converts to string with two decimal place" do
    c = Currency.new(3.33)
    c.to_s.should == "3.33"
  end
  
  it "has equality with Fixnum" do
    c = Currency.new(10)
    c.should == 10
    c.should_not == 9
  end
  
  it "has equality with Float" do
    c = Currency.new(1.11)
    c.should == 1.11
    c.should_not == 9.0
  end
  
  it "has equality with Currency" do
    c = Currency.new(10)
    c.should == Currency.new(10.0)
  end
  
  it "adds like a Float" do
    c = Currency.new(3.33)
    d = c + 10.3
    d.is_a?(Currency).should == true
    d.should == 13.63
    d += 0.33
    d.should == 13.96
  end

  it "subtracts like a Float" do
    c = Currency.new(3.33)
    d = c - 3
    d.is_a?(Currency).should == true
    d.should == 0.33
    d -= 0.33
    d.should == 0
  end

  it "multiplies like a Float" do
    c = Currency.new(3.33)
    d = c * 3
    d.is_a?(Currency).should == true
    d.should == 9.99
  end

  it "divides like a Float" do
    c = Currency.new(3.33)
    d = c / 3
    d.is_a?(Currency).should == true
    d.should == 1.11
  end

  it "compares to a Float" do
    c = Currency.new(3.33)
    (c > 3.0).should == true
    (c < 4.0).should == true
    (c <=> 4.0).should == -1
    (c <=> 3.0).should == 1
    (c <=> 3.33).should == 0
  end

  it "compares to a Fixnum" do
    c = Currency.new(3.33)
    (c > 3).should == true
    (c < 4).should == true
    (c <=> 4).should == -1
    (c <=> 3).should == 1
  end
  
  it "compares to a Currency" do
    c = Currency.new(3.33)
    (c > Currency.new(3)).should == true
    (c < Currency.new(4)).should == true
    (c <=> Currency.new(4)).should == -1
    (c <=> Currency.new(3)).should == 1
  end
  
  it "handles negatives" do
    c = Currency.new(-13.33)
    c.should be < 0
    (c*c).should be > 0
  end

  it "abs works" do
    c = Currency.new(13.33)
    c.abs.should == 13.33
    c = Currency.new(-13.33)
    c.abs.should == 13.33
    c.abs.should_not === c
  end

end