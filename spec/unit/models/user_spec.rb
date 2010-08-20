require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe User do
  it "default_workgroup is created on user creation" do
    user = Factory(:user)
    user.default_workgroup.is_a?( Workgroup ).should == true
    user.workgroups.include?( user.default_workgroup ).should == true
    user.default_workgroup.users.include?( user ).should == true
  end
end