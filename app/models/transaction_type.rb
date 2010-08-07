class TransactionType
  NAMES_TO_IDS = { 'DEB'=>1, 'CRD'=>2, 'INT'=>3 }
  TYPES_TO_IDS = {:debit=>1, :credit=>2, :interest=>3}
  IDS_TO_NAMES = NAMES_TO_IDS.invert
  IDS_TO_TYPES = TYPES_TO_IDS.invert
  IDS = IDS_TO_NAMES.keys
  TYPES = TYPES_TO_IDS.keys
  NAMES = NAMES_TO_IDS.keys
  
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
