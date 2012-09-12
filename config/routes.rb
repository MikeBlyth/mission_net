Joslink::Application.routes.draw do

scope "(:locale)", :locale => /en|fr/ do
  resources :system_notes do as_routes end

  resources :cities do as_routes end

  get "sessions/new"
  get "sessions/safe_page", :as => 'safe_page'
  get '/:controller/export', :action => 'export'
  match '/:controller/import', :action => 'import'

   get   'admin/site_settings' => 'site_settings#edit', :as=>'site_settings'
   get   'admin/site_settings/index' => 'site_settings#index', :as=>'index_site_settings'
   put  'admin/site_settings' => 'site_settings#update', :as=>'update_site_settings'
  resources :app_logs do as_routes end
  resources :bloodtypes do as_routes end
  resources :incoming_mails do as_routes end
  resources :countries do as_routes end
  match 'groups/member_count'
  resources :groups do as_routes end
  resources :incoming_mails do as_routes end
  resources :locations do as_routes end
  match "sent_messages/clickatell_status",  :to => "sent_messages#update_status_clickatell"
  get "messages/:id/followup", :to => "messages#followup"
  match "messages/:id/followup_send", :to => "messages#followup_send"
  get "members/wife_select", :to => 'members#wife_select'
  resources :members do as_routes end
  resources :messages do as_routes end
  resources :sent_messages do as_routes end
  resources :sms
  match 'reports/index' => 'reports#index', :as => 'reports'
  match 'reports/directory' => 'reports#directory', :as => 'directory'

  get   '/login', :to => 'sessions#new', :as => :sign_in
  get   '/signin', :to => 'sessions#new', :as => :sign_in  # signin is just an alias for login
  get '/logout', :to => 'sessions#destroy', :as => :sign_out
  get '/signout', :to => 'sessions#destroy', :as => :sign_out  # signout is just an alias for logout
  match '/auth/:provider/callback', :to => 'sessions#create', :as => :create_session
  match '/signin_test', :to => 'sessions#create', :as => :create_test_session
  match '/auth/failure', :to => 'sessions#failure'
  get '/setup', :to => 'setup#initialize', :as => :initialize
  post '/setup', :to => 'setup#initialize_save'

#  resources :users do
#    member do
#      get 'edit_roles'
#      put 'update_roles'
#    end
#  end

  match '/:locale' => 'members#index'
  get "/home", :to => "members#index", :as => :home
  root :to => "members#index"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
end

