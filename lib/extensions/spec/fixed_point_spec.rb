require 'spec/autorun'
require 'spec/runner/formatter/text_mate_formatter'
require File.dirname(__FILE__) + '/../fixed_point'

describe FixedPoint do
  it "defaults to zero on creation" do
    c = FixedPoint.new
    c.should == 0
  end
  
  it "initializes from a floating point number" do
    c = FixedPoint.new(3.33)
  end
  
  it "initializes from a string" do
    c = FixedPoint.new('3.33')
    c.value.should == 333
  end
  
  it "converts to string with two decimal place" do
    c = FixedPoint.new(3.33)
    c.to_s.should == "3.33"
  end
  
  it "has equality with Fixnum" do
    c = FixedPoint.new(10)
    c.should == 10
    c.should_not == 9
  end
  
  it "has equality with Float" do
    c = FixedPoint.new(1.11)
    c.should == 1.11
    c.should_not == 9.0
  end
  
  it "has equality with FixedPoint" do
    c = FixedPoint.new(10)
    c.should == FixedPoint.new(10.0)
  end
  
  it "adds like a Float" do
    c = FixedPoint.new(3.33)
    d = c + 10.3
    d.is_a?(FixedPoint).should == true
    d.should == 13.63
    d += 0.33
    d.should == 13.96
  end

  it "subtracts like a Float" do
    c = FixedPoint.new(3.33)
    d = c - 3
    d.is_a?(FixedPoint).should == true
    d.should == 0.33
    d -= 0.33
    d.should == 0
  end

  it "multiplies like a Float" do
    c = FixedPoint.new(3.33)
    d = c * 3
    d.is_a?(FixedPoint).should == true
    d.should == 9.99
  end

  it "divides like a Float" do
    c = FixedPoint.new(3.33)
    d = c / 3
    d.is_a?(FixedPoint).should == true
    d.should == 1.11
  end
  
  it "adds with itself" do
    a = FixedPoint.new(11.12)
    b = FixedPoint.new(2.12)
    (a+b).should == 13.24
  end

  it "multiplies with itself" do
    a = FixedPoint.new(11.12)
    b = FixedPoint.new(2.00)
    (a*b).should == 22.24
  end

  it "multiplies with itself at different precisions" do
    a = FixedPoint.new(1000.00)
    b = FixedPoint.new(0.005, nil, 4)
    c = (a*b)
    c.should == 5
  end

  it "keeps the left operator's precision when multiplying with itself" do
    a = FixedPoint.new(1000.00)
    b = FixedPoint.new(0.005, nil, 4)
    c = (b*a)
    c.precision.should == 4
  end

  it "compares to a Float" do
    c = FixedPoint.new(3.33)
    (c > 3.0).should == true
    (c < 4.0).should == true
    (c <=> 4.0).should == -1
    (c <=> 3.0).should == 1
    (c <=> 3.33).should == 0
  end

  it "compares to a Fixnum" do
    c = FixedPoint.new(3.33)
    (c > 3).should == true
    (c < 4).should == true
    (c <=> 4).should == -1
    (c <=> 3).should == 1
  end
  
  it "compares to a FixedPoint" do
    c = FixedPoint.new(3.33)
    (c > FixedPoint.new(3)).should == true
    (c < FixedPoint.new(4)).should == true
    (c <=> FixedPoint.new(4)).should == -1
    (c <=> FixedPoint.new(3)).should == 1
  end
  
  it "handles negatives" do
    c = FixedPoint.new(-13.33)
    c.should be < 0
    (c*c).should be > 0
  end

  it "abs works" do
    c = FixedPoint.new(13.33)
    c.abs.should == 13.33
    c = FixedPoint.new(-13.33)
    c.abs.should == 13.33
    c.abs.should_not === c
  end

end