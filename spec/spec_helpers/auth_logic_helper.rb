module AuthLogicSpecHelper
  USER_ID = 12345
  def current_user(stubs = {})
    @current_user ||= mock_model(User, stubs.merge(:time_zone=>'Central Time (US & Canada)'))
  end
 
  def user_session(stubs = {}, user_stubs = {})
    @current_session ||= mock_model(UserSession, {:user => current_user(user_stubs)}.merge(stubs))
  end
 
  def login(session_stubs = {}, user_stubs = {})
    UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
  end
 
  def logout
    @user_session = nil
  end

  def setup_root_user( user_stubs={} )
    @workgroups = Workgroup.all
    @user_login = "root"
    @role = mock_model(Role, {:name=>"Role Name"})
    @agency = mock_model(Agency, {:name=>"Agency"})
    login({},user_stubs.merge({:is_superuser=>true,
      :id=>USER_ID,
      "is_superuser?"=>true,
      :login=>@user_login,
      :role=>@role,
      :allowed_workgroups=>@workgroups,
      :deleted=>nil,
      :agency=>@agency,
      :full_name=>"Some User",
      :email_address=>"user@user.com",
      "can_access_workgroup?"=>true,
      "can_index__searches?"=>true,
      "can_index__roles?"=>true,
      "can_index__workgroups?"=>true,
      "can_index__users?"=>true,
      "can_edit__topics?"=>true,
      "can_destroy__topics?"=>true,
      "can_remove_all_posts__topics?"=>true,
      "can_remove_post__topics?"=>true,
      "can_review__topic_posts?"=>true,
      "can_edit_buzz__topics?"=>true,
      "can_admin__workgroups?"=>true,
      "prompt_for_ignore_post"=>false,
      "has_sentiment_term_highlighting_privilege?"=>false,
      "has_keyword_topic_searching_privilege?"=>false,
      }))
  end

  def setup_regular_user( login, agency, user_params={}, action_permissions=[], all_workgroups=false )
    user_params ||= {}
    role = Role.find_by_name("Role")
    role.destroy if role
    @role = Role.create!({:name=>"Role", :description=>"Role description"})
    ActionPermission.create!({:controller_name=>"workgroups", :action_name=>"show", :permission_set_id=>@role.id})
    ActionPermission.create!({:controller_name=>"topics", :action_name=>"show", :permission_set_id=>@role.id})
    ActionPermission.create!({:controller_name=>"workgroups", :action_name=>"index", :permission_set_id=>@role.id})
    ActionPermission.create!({:controller_name=>"topics", :action_name=>"index", :permission_set_id=>@role.id})
    action_permissions.each do |permission|
      ActionPermission.create!({:controller_name=>permission.first, :action_name=>permission.last, :permission_set_id=>@role.id})
    end
    new_user_params = {
      :login=>login, 
      :password=>"password", 
      :password_confirmation=>"password",
      :full_name=>"User's Full Name",
      :email_address=>"email@email.com",
      :agency_id=>agency.id,
      :role_id=>@role.id,
      :all_workgroups=>all_workgroups
    }
    user = User.find_by_login(login)
    user.destroy if user
    @current_user = @user = User.create!( new_user_params.merge(user_params) )
    @current_session ||= mock_model(UserSession, {:user => @user})
    UserSession.stub!(:find).and_return(@current_session)
  end
end
