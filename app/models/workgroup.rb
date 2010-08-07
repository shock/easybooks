class Workgroup < ActiveRecord::Base
  has_many :workgroups_users, :class_name=>'WorkgroupsUsers'
  has_many :users, :through=>:workgroups_users
  has_many :accounts, :dependent=>:destroy
  has_many :institutions, :dependent=>:destroy
  
  before_destroy :before_destroy_callback
  
  private
    def before_destroy_callback
      user = User.find_by_default_workgroup(self)
      raise "Can't delete default workgroup for user '#{user.login}'.  Change user's default workgroup, then try again." if user
    end
end
