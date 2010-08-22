require 'bigdecimal'

class FixedPoint
  
  PRECISION = 2
  
  ARITHMETIC_METHODS = %w{+ -}
  COMPARE_METHODS = %w{> < >= <= <=>}
  
  attr :value
  attr :factor
  attr :precision
  
  def initialize( initial = 0.0, raw_value = nil, precision=PRECISION )
    @precision = precision
    @factor = 10**@precision
    if raw_value
      @value = raw_value
    else
      @value =  (BigDecimal.new(initial.to_s.gsub(',',''), precision)*@factor).to_i
    end
  end
  
  def to_s
    @value.to_s
    "%.0#{@precision}f" % (@value.to_f/@factor)
  end
  
  def to_i
    (@value / @factor).to_i
  end
  
  def == obj
    if obj.is_a? Numeric
      @value == (obj * @factor).to_i
    elsif obj.is_a? FixedPoint
      @value == obj.value
    else
      false
    end
  end
  
  def abs
    if @value > 0
      FixedPoint.new(0, @value, @precision)
    else
      FixedPoint.new(0, -@value, @precision)
    end
  end
  
  def -@
    FixedPoint.new(0, -@value, @precision)
  end
  
  def *( arg )
    if arg.is_a? FixedPoint
      result = (@value * arg.value)/arg.factor
    else
      result = (@value * (arg*@factor).to_i) / @factor
    end
    new_obj = FixedPoint.new(0, result.to_i, @precision)
  end
  
  def /( arg )
    if arg.is_a? FixedPoint
      result = (@value*arg.factor) * arg.value
    else
      result = (@value*@factor) / (arg*@factor).to_i
    end
    new_obj = FixedPoint.new(0, result.to_i, @precision)
  end
  
  def method_missing method, *args
    if ARITHMETIC_METHODS.include? method.to_s
      arg = (args[0] * @factor).to_i
      result = @value.send(method, arg)
      new_obj = FixedPoint.new(0, result.to_i, @precision)
    elsif COMPARE_METHODS.include? method.to_s
      arg = (args[0] * @factor).to_i
      result = @value.send(method, arg)
    else
      super
    end
  end
  
end



