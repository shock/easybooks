require 'bigdecimal'

class Currency
  
  PRECISION = 2
  FACTOR = 10**PRECISION
  
  ARITHMETIC_METHODS = %w{* / + -}
  COMPARE_METHODS = %w{> < >= <= <=>}
  
  attr :value
  def initialize( initial = 0.0, raw_value = nil )
    if raw_value
      @value = raw_value
    else
      @value =  (BigDecimal.new(initial.to_s.gsub(',',''), PRECISION)*FACTOR).to_i
    end
  end
  
  def to_s
    @value.to_s
    '%.02f' % (@value.to_f/FACTOR)
  end
  
  def to_i
    (@value / FACTOR).to_i
  end
  
  def == obj
    case obj.class.to_s
    when 'Fixnum', 'Float'
      @value == (obj * FACTOR).to_i
    when 'Currency'
      @value == obj.value
    else
      false
    end
  end
  
  def abs
    if @value > 0
      Currency.new(0, @value)
    else
      Currency.new(0, -@value)
    end
  end

  def method_missing method, *args
    if ARITHMETIC_METHODS.include? method.to_s
      case method
      when :*
        arg = (args[0] * FACTOR).to_i
        result = @value.send(method, arg) / FACTOR
      when :/
        arg = (args[0] * FACTOR).to_i
        result = (@value*FACTOR).send(method, arg)
      else
        arg = (args[0] * FACTOR).to_i
        result = @value.send(method, arg)
      end
      new_obj = Currency.new(0, result.to_i)
    elsif COMPARE_METHODS.include? method.to_s
      arg = (args[0] * FACTOR).to_i
      result = @value.send(method, arg)
    else
      super
    end
  end
  
end



