Aed::Application.routes.draw do

  get 'api/autocomplete'

  get 'api/csv_dump'

  get 'api/help'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: { registrations: 'users/registrations' }

  resources :changes

  resources :analyses
  get 'input_zone_export/:analysis/:year' => 'analyses#export'

  resources :range_previews
  get 'range_preview_map' => 'range_previews#map'

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
    resources :survey_modeled_extrapolations
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
  resources :survey_modeled_extrapolations
  resources :survey_others

  resources :population_submission_attachments

  get 'population_submission_attachments/download/:id' => 'population_submission_attachments#download'
  get 'population_submissions/:id/map' => 'population_submissions#geojson_map'
  get 'survey_geometry/:id/map' => 'survey_geometries#geojson_map'
  get 'survey_geometry/:id/download' => 'survey_geometries#download'

  namespace :api, module: nil do
    # input zone endpoints
    get 'input_zones' => 'input_zones#index'
    get 'input_zone/:id/strata' => 'input_zones#strata'
    get 'input_zone/:id/geojson_map' => 'input_zones#geojson_map'
    get 'input_zone/:id/data' => 'input_zones#data'

    # population endpoints
    get 'populations' => 'populations#index'
    get 'population/:id/input_zones' => 'populations#input_zones'
    get 'population/:id/geojson_map' => 'populations#geojson_map'

    # country endpoints
    get 'countries' => 'countries#index'
    get 'country/:iso_code/populations' => 'countries#populations'
    get 'country/:iso_code/geojson_map' => 'countries#geojson_map'
    get 'country/:iso_code/:year/dpps' => 'countries#dpps'
    get 'country/:iso_code/:year/add' => 'countries#add'
    get 'country/:iso_code/narrative' => 'countries#narrative'
    get 'country/:iso_code/boilerplate_data' => 'countries#boilerplate_data'

    # region endpoints
    get 'regions' => 'regions#index'
    get 'region/:id/countries' => 'regions#countries'
    get 'region/:id/geojson_map' => 'regions#geojson_map'
    get 'region/:id/:year/dpps' => 'regions#dpps'
    get 'region/:id/:year/add' => 'regions#add'
    get 'region/:id/narrative' => 'regions#narrative'
    get 'region/:id/boilerplate_data' => 'regions#boilerplate_data'

    # continent endpoints
    get 'continents' => 'continents#index'
    get 'continent/:id/regions' => 'continents#regions'
    get 'continent/:id/geojson_map' => 'continents#geojson_map'
    get 'continent/:id/:year/dpps' => 'continents#dpps'
    get 'continent/:id/:year/add' => 'continents#add'
    get 'continent/:id/narrative' => 'continents#narrative'
    get 'continent/:id/boilerplate_data' => 'continents#boilerplate_data'

    # misc endpoints
    get 'stratum/:strcode/geojson_map' => 'api#strata_geojson'
    get 'stratum/:strcode/data' => 'api#strata_data'
    get 'analysis/years' => 'analyses#years'
    get 'add_dump' => 'api#add_dump', defaults: { format: :json }
    get 'boilerplate_dump' => 'api#boilerplate_dump', defaults: { format: :json }
    get 'boilerplate_data_dump' => 'api#boilerplate_data_dump', defaults: { format: :json }
    get 'autocomplete' => 'api#autocomplete'

    # TODO deprecate after new URL is used
    get 'known/geojson_map' => 'api#known_geojson'
    get 'possible/geojson_map' => 'api#possible_geojson'
    get 'doubtful/geojson_map' => 'api#doubtful_geojson'
    get 'protected/geojson_map' => 'api#protected_geojson'

    get 'range/known/geojson_map' => 'api#known_geojson'
    get 'range/possible/geojson_map' => 'api#possible_geojson'
    get 'range/doubtful/geojson_map' => 'api#doubtful_geojson'
    get 'range/protected/geojson_map' => 'api#protected_geojson'
  end

  get 'country/:iso_code/geojson_strata' => 'countries#geojson_strata'
  get 'country/survey_map/:iso_code/:analysis/:year' => 'countries#geojson_map_public'
  get 'data_request_forms/new' => 'data_request_forms#hold'
  get 'secret_data_request_forms/thanks' => 'data_request_forms#thanks'

  resources :data_request_forms, path: 'secret_data_request_forms'

  resources :spreadsheets, only: [:index, :create, :show, :destroy]

  get 'about' => 'about#index'
  get 'about/darp' => 'about#darp'

  get 'superuser' => 'superuser#index'

  get 'report/references' => 'report#references'
  get 'report/:year/:continent/:region/:country/:survey' => 'report#survey'
  get 'report/:year/:continent/:region/:country' => 'report#country'
  get 'report/:year/:continent/:region' => 'report#region'
  get 'report/:year/:continent' => 'report#continent'
  get 'report/appendix_1/:filter' => 'report#appendix_1'
  get 'report/appendix_2/:filter' => 'report#appendix_2'
  get 'report/general_statistics/' => 'report#general_statistics'
  get 'report/:year/:continent/corrections' => 'report#corrections'
  get 'report/:year/:continent/site/:site' => 'report#site'
  get 'report//bibliography' => 'report#bibliography'
  get 'report/:year' => 'report#year'
  get 'report' => 'report#species'

  get 'find/:year/:objectid' => 'find#historical'
  get 'range_popup/:source_id' => 'find#range_popup'
  get 'popup/:year/:objectid' => 'find#popup'

  get 'population_submissions/:id/submit' => 'population_submissions#submit'
  get 'my_population_submissions' => 'population_submissions#my'

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
