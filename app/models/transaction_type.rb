class TransactionType
  # These types are based on the types defined by the OFX data format.
  TYPES_DEF = {
    :DEBIT       => [1,'DEB'],
    :CREDIT      => [2, 'CRD'],
    :INT         => [3, 'INT'],
    :DIV         => [5, "DIV"],
    :FEE         => [6, "FEE"],
    :SRVCHG      => [7, "CHRG"],
    :DEP         => [8, "DEP"],
    :ATM         => [9, "ATM"],
    :POS         => [10, "POS"],
    :XFER        => [11, "XFR"],
    :CHECK       => [12, "CHK"],
    :PAYMENT     => [13, "PMT"],
    :CASH        => [14, "CSH"],
    :DIRECTDEP   => [15, "DDEP"],
    :DIRECTDEBIT => [16, "DDEB"],
    :REPEATPMT   => [17, "RPMT"],
    :OTHER       => [18, "OTH"]
  }
  TYPES_TO_IDS = {}
  TYPES_TO_NAMES = {}
  NAMES_TO_IDS = {}
  
  TYPES_DEF.each do |type, defin|
    id = defin.first
    name = defin.last
    NAMES_TO_IDS[name] = id
    TYPES_TO_NAMES[type] = name
    TYPES_TO_IDS[type] = id
  end

  IDS = TYPES_TO_IDS.values
  TYPES = TYPES_TO_IDS.keys
  NAMES = NAMES_TO_IDS.keys

  IDS_TO_TYPES = TYPES_TO_IDS.invert
  IDS_TO_NAMES = NAMES_TO_IDS.invert
  NAMES_TO_TYPES = TYPES_TO_NAMES.invert
  
  TYPES_TO_IDS.freeze
  TYPES_TO_NAMES.freeze
  NAMES_TO_IDS.freeze
  NAMES_TO_TYPES.freeze
  IDS_TO_TYPES.freeze
  IDS_TO_NAMES.freeze
  
  attr_accessor :id, :name
  
  def initialize( id )
    @id = id
  end
  
  def valid?
    name.is_a?( String ) && name.size > 0 && name == IDS_TO_NAMES[id]
  end
  
  def name
    IDS_TO_NAMES[id]
  end
  
  def type
    IDS_TO_TYPES[id]
  end
  
  def == obj
    if obj.is_a? Symbol
      self.type == obj
    else
      super
    end
  end
  
  def to_s
    self.type.to_s
  end
  
  def method_missing method, *args
    if matches = method.to_s.match( /is_(\w*)?/ )
      type = matches[1].upcase.to_sym
      raise "Unknown Transaction Type: #{type.inspect}" unless TYPES.include? type
      self.type == type
    else
      super
    end
  end
  
  class << self
    def method_missing method, *args
      type = method.to_s.upcase.to_sym
      if TYPES.include? type
        TransactionType.new( TYPES_TO_IDS[type] )
      else
        super
      end
    end
    
    def find( id )
      return TransactionType.all if id == :all
      name = IDS_TO_NAMES[id.to_i]
      raise "Unknown Transaction Type ID: #{id.inspect}" unless name
      TransactionType.new( id )
    end

    def find_by_name( name )
      id = NAMES_TO_IDS[name]
      raise "Unknown Transaction Name: #{name.inspect}" unless id
      TransactionType.new( id )
    end

    def find_by_type( type )
      id = TYPES_TO_IDS[type]
      raise "Unknown Transaction Type: #{type.inspect}" unless id
      TransactionType.new( id )
    end
    
    def all
      IDS.map{|id| TransactionType.find(id)}
    end
    
  end
    
end
