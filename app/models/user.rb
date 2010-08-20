class User < ActiveRecord::Base
  acts_as_authentic do |c|
    # c.my_config_option = my_value # for available options see documentation in: Authlogic::ActsAsAuthentic
  end # block optional
  
  has_many :workgroups_users, :class_name=>'WorkgroupsUsers'
  has_many :workgroups, :through=>:workgroups_users
  belongs_to :default_workgroup, :foreign_key=>:default_workgroup_id, :class_name=>'Workgroup'
  
  before_validation :ensure_workgroup
  
  validates_presence_of :default_workgroup
  
  def is_admin?
    admin_flag
  end
  
  def institutions
    Institution.all.by_user
  end
  
  def accounts
    Account.all.by_user
  end

  def categories
    Category.all.by_user
  end
  # private
    
    def ensure_workgroup
      unless default_workgroup
        self.default_workgroup = Workgroup.find_or_create_by_name(self.login)
        self.workgroups << self.default_workgroup
      end
    end
end
