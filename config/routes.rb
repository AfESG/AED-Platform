Aaed::Application.routes.draw do
  resources :survey_individual_registrations

  resources :survey_others

  resources :survey_faecal_dna_strata

  resources :survey_faecal_dnas

  resources :survey_dung_count_line_transect_strata

  resources :survey_dung_count_line_transects

  resources :survey_ground_sample_count_strata

  resources :survey_ground_sample_counts

  resources :survey_ground_total_count_strata

  resources :survey_ground_total_counts

  resources :survey_aerial_sample_count_strata

  resources :survey_aerial_sample_counts

  resources :survey_aerial_total_count_strata

  resources :survey_aerial_total_counts

  resources :population_submissions

  resources :submissions

  match 'data_request_forms/thanks' => 'data_request_forms#thanks'
  resources :data_request_forms

  devise_for :users

  match 'about' => 'about#index'
  match 'about/darp' => 'about#darp'

  match 'superuser' => 'superuser#index'

  match 'report/:year/:continent/:region/:country' => 'report#country'
  match 'report/:year/:continent/:region' => 'report#region'
  match 'report/:year/:continent' => 'report#continent'
  match 'report/:year' => 'report#year'

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

  root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
