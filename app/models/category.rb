class Category < ActiveRecord::Base
  has_many :transactions
  belongs_to :workgroup
  acts_as_tree
 
  validates_presence_of :name, :workgroup
  before_validation :ensure_workgroup

  def ensure_workgroup
    workgroup ||= current_user.try(:default_workgroup)
  end
  private :ensure_workgroup

  def ancestors_name
    if parent
      parent.ancestors_name + parent.name + ':'
    else
      ""
    end
  end

  def long_name
    ancestors_name + name
  end
  
  def self.find_tree parent_id
    results = []
    children = find(:all, :conditions => { :parent_id => parent_id }, :order => 'name')
    for child in children
      results << child
      results += self.find_tree child.id
    end
    results
  end

  def self.sorted_find_all workgroup_id
    results = []
    root = root_for_workgroup workgroup_id
    if( root )
      results[0] = root
      results += self.find_tree( root.id )
    end
    results
  end
  
  def self.root_for_workgroup workgroup_id
    Category.new(:id=>nil, :name=>'None', :workgroup_id=>workgroup_id)
  end
  
end
