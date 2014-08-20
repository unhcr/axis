Visio::Application.routes.draw do
  devise_for :users, :controllers => {:sessions => 'sessions', :registrations => 'registrations' }

  # Application
  get '/splash' => 'application#splash'
  get '/algorithms' => 'application#algorithms'
  get '/map' => 'application#map'
  get '/overview/:strategy_id' => 'application#overview'
  get '/operation/:operation_id' => 'application#operation'
  get '/indicator/:indicator_id' => 'application#indicator'

  get '/global_search' => 'application#global_search'
  get '/healthz' => 'application#healthz'
  get '/reset_local_db' => 'application#reset_local_db'
  get '/create_guest_user' => 'application#create_guest_user'

  # CMS
  get '/cms/strategies' => 'cms#strategies'

  # Resources
  syncable_resources :operations
  # hack, should be a more semantic way to do this
  get '/operations/:id/offices' => 'operations#offices'
  get '/operations/:id/head_offices' => 'operations#head_offices'


  syncable_resources :plans
  syncable_resources :ppgs
  syncable_resources :goals
  syncable_resources :rights_groups
  syncable_resources :problem_objectives
  syncable_resources :outputs
  syncable_resources :indicators
  syncable_resources :indicator_data
  syncable_resources :budgets
  syncable_resources :expenditures
  syncable_resources :offices
  resources :export_modules do
    member do
      get 'pdf'
      get 'email'
    end
  end
  resources :strategy_objectives do
    collection do
      get 'search'
    end
  end
  resource :admin_configuration, :controller => :admin_configuration
  resources :strategies do
    member do
      get 'download'
    end
    collection do
      get 'normalize'
    end
  end
  resources :users do
    member do
      post 'share/:strategy_id' => 'users#share'
    end
    collection do
      get 'search'
      post 'admin' => 'users#admin'
    end
  end

  root :to => 'application#index'
end
