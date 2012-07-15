Joslink::Application.routes.draw do

  get "sessions/new"
  get '/:controller/export', :action => 'export'
  match '/:controller/import', :action => 'import'

  resources :app_logs do as_routes end
  resources :bloodtypes do as_routes end
  resources :incoming_mails do as_routes end
  resources :countries do as_routes end
  resources :groups do as_routes end
  resources :incoming_mails do as_routes end
  resources :locations do as_routes end
  resources :members do as_routes end
    match "sent_messages/clickatell_status",  :to => "sent_messages#update_status_clickatell"
    get "messages/:id/followup", :to => "messages#followup"
    match "messages/:id/followup_send", :to => "messages#followup_send"
  resources :messages do as_routes end
  resources :sent_messages do as_routes end
  resources :sms

  get   '/login', :to => 'sessions#new', :as => :sign_in
  get '/logout', :to => 'sessions#destroy'
  get   '/signin', :to => 'sessions#new', :as => :sign_in
  get '/signout', :to => 'sessions#destroy'
  match '/auth/:provider/callback', :to => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  get '/setup', :to => 'setup#initialize', :as => :initialize
  post '/setup', :to => 'setup#initialize_save'

#  resources :users do
#    member do
#      get 'edit_roles'
#      put 'update_roles'
#    end
#  end

  get "/home", :to => "members#list", :as => :home
  root :to => "members#list"
  
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
