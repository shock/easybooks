ActionController::Routing::Routes.draw do |map|
  map.resources :categories

  map.resources :transactions

  map.resources :accounts do |account|
  end
  map.account_reconcile 'accounts/:id/reconcile', :controller=>'accounts', :action=>'show_reconcile_batch'

  map.resources :institutions

  map.resources :workgroups

  map.resources :financial_files

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # config/routes.rb
  map.resource :user_session
  map.root :controller => "accounts", :action => "index" # optional, this just sets the root route

  map.resource :user_account, :controller => "users"
  map.resources :users
  map.connect 'logout', :controller => "user_sessions", :action=>'destroy'
  map.connect 'register', :controller => "users", :action=>'new'

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
