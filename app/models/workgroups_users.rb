class WorkgroupsUsers < ActiveRecord::Base
  belongs_to :workgroup
  belongs_to :user
end
