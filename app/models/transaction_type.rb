class TransactionType
  TYPES_DEF = {
    :debit=>[1,'DEB'],
    :credit=>[2, 'CRD'],
    :interest=>[3, 'INT'],
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
  
  def method_missing method, *args
    if matches = method.to_s.match( /is_(\w*)?/ )
      type = matches[1].to_sym
      raise "Unknown Transaction Type: #{type.inspect}" unless TYPES.include? type
      self.type == matches[1].to_sym
    else
      super
    end
  end
  
  class << self
    def debit; TransactionType.new( TYPES_TO_IDS[:debit]); end
    def credit; TransactionType.new( TYPES_TO_IDS[:credit]); end
    def interest; TransactionType.new( TYPES_TO_IDS[:interest]); end
    
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
