require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Main Factory Spec" do
  it "creates and persists associated objects properly" do
    workgroup = Factory(:workgroup)
    workgroup.id.should_not == nil
  end
  
  it "creates a valid user model" do
    user = Factory(:user)
    user.email.should == "#{user.login}@#{user.login}.com"
  end
  
  it "creates all models valid" do
    Factory(:user)
    Factory(:workgroup)
    Factory(:institution)
    Factory(:account)
    Factory(:transaction)
    Factory(:category)
  end

end