class Institution < ActiveRecord::Base
  has_many :accounts
  belongs_to :workgroup

  before_validation :ensure_workgroup
  validates_presence_of :workgroup, :name

  def ensure_workgroup
    self.workgroup ||= current_user.try(:default_workgroup)
  end
  private :ensure_workgroup

end
