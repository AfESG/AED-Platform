Aaed::Application.routes.draw do

  get 'continents/index'

  get 'continents/geojson_map'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users

  resources :changes

  resources :analyses
  get 'input_zone_export/:analysis/:year' => 'analyses#export'

  resources :report_narratives

  resources :users

  get 'add-data' => 'submissions#add'
  resources :submissions do
    resources :population_submissions
  end

  resources :population_submissions do
    resources :survey_aerial_sample_counts
    resources :survey_aerial_total_counts
    resources :survey_dung_count_line_transects
    resources :survey_faecal_dnas
    resources :survey_ground_sample_counts
    resources :survey_ground_total_counts
    resources :survey_individual_registrations
    resources :survey_others
    resources :population_submission_attachments
    resources :linked_citations
  end

  resources :linked_citations

  resources :survey_aerial_sample_counts do
    resources :survey_aerial_sample_count_strata
  end
  resources :survey_aerial_sample_count_strata

  resources :survey_aerial_total_counts do
    resources :survey_aerial_total_count_strata
  end
  resources :survey_aerial_total_count_strata

  resources :survey_dung_count_line_transects do
    resources :survey_dung_count_line_transect_strata
  end
  resources :survey_dung_count_line_transect_strata

  resources :survey_faecal_dnas do
    resources :survey_faecal_dna_strata
  end
  resources :survey_faecal_dna_strata

  resources :survey_ground_sample_counts do
    resources :survey_ground_sample_count_strata
  end
  resources :survey_ground_sample_count_strata

  resources :survey_ground_total_counts do
    resources :survey_ground_total_count_strata
  end
  resources :survey_ground_total_count_strata

  resources :survey_individual_registrations
  resources :survey_others

  resources :population_submission_attachments

  get 'population_submission_attachments/download/:id' => 'population_submission_attachments#download'
  get 'population_submissions/:id/map' => 'population_submissions#geojson_map'
  get 'survey_geometry/:id/map' => 'survey_geometries#geojson_map'

  # country endpoints
  get 'countries' => 'countries#index'
  get 'country/:iso_code/map' => 'countries#geojson_map'
  get 'country/survey_map/:iso_code/:analysis/:year' => 'countries#geojson_map_public'

  # region endpoints
  get 'regions' => 'regions#index'
  get 'region/:id/map' => 'regions#geojson_map'

  # continent endpoints
  get 'continents' => 'continents#index'
  get 'continent/:id/map' => 'continents#geojson_map'

  get 'data_request_forms/thanks' => 'data_request_forms#thanks'

  resources :data_request_forms

  resources :spreadsheets, only: [:index, :create, :show, :destroy]

  get 'about' => 'about#index'
  get 'about/darp' => 'about#darp'

  get 'superuser' => 'superuser#index'

  get 'report/references' => 'report#references'
  get 'report/:year/:continent/:region/:country/:survey' => 'report#survey'
  get 'report/:year/:continent/:region/:country' => 'report#country'
  get 'report/:year/:continent/:region' => 'report#region'
  get 'report/:year/:continent' => 'report#continent'
  get 'preview_report/:filter/:year/:continent' => 'report#preview_continent'
  get 'preview_report/:filter/:year/:continent/corrections' => 'report#preview_corrections'
  get 'preview_report/:filter/:year/:continent/:region' => 'report#preview_region'
  get 'preview_report/:filter/:year/:continent/site/:site' => 'report#preview_site'
  get 'preview_report/:filter/:year/:continent/:region/:country' => 'report#preview_country'
  get 'preview_report/:filter/bibliography' => 'report#bibliography'
  get 'report/:year' => 'report#year'
  get 'report' => 'report#species'

  get 'find/:year/:objectid' => 'find#historical'
  get 'range_popup/:source_id' => 'find#range_popup'
  get 'popup/:year/:objectid' => 'find#popup'

  get 'population_submissions/:id/submit' => 'population_submissions#submit'
  get 'my_population_submissions' => 'population_submissions#my'

  get 'analysis_2013' => 'population_submissions#analysis_2013'

  get 'species/:species_id/range_states' => 'species#range_states'

  get 'mike_report' => 'welcome#mike_report'
  get 'reliability' => 'welcome#reliability'

  get 'crash' => 'welcome#crash'
  get 'recalc' => 'welcome#recalc'

  get 'submission_search' => 'submission_search#index'

  get 'history/:item_type/:id' => 'versions#history'

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
