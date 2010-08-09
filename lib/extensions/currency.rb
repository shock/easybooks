require 'bigdecimal'

class Currency
  
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
    case obj.class.to_s
    when 'Fixnum', 'Float'
      @value == (obj * @factor).to_i
    when 'Currency'
      @value == obj.value
    else
      false
    end
  end
  
  def abs
    if @value > 0
      Currency.new(0, @value, @precision)
    else
      Currency.new(0, -@value, @precision)
    end
  end
  
  def *( arg )
    if arg.is_a? Currency
      result = (@value * arg.value)/arg.factor
    else
      result = (@value * (arg*@factor).to_i) / @factor
    end
    new_obj = Currency.new(0, result.to_i, @precision)
  end
  
  def /( arg )
    if arg.is_a? Currency
      result = (@value*arg.factor) * arg.value
    else
      result = (@value*@factor) / (arg*@factor).to_i
    end
    new_obj = Currency.new(0, result.to_i, @precision)
  end
  
  def method_missing method, *args
    if ARITHMETIC_METHODS.include? method.to_s
      arg = (args[0] * @factor).to_i
      result = @value.send(method, arg)
      new_obj = Currency.new(0, result.to_i, @precision)
    elsif COMPARE_METHODS.include? method.to_s
      arg = (args[0] * @factor).to_i
      result = @value.send(method, arg)
    else
      super
    end
  end
  
end



