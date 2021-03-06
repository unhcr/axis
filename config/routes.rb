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
  visio_resources :operations
  # hack, should be a more semantic way to do this
  get '/operations/:id/offices' => 'operations#offices'
  get '/operations/:id/head_offices' => 'operations#head_offices'


  visio_resources :plans
  visio_resources :ppgs
  visio_resources :goals
  visio_resources :rights_groups
  visio_resources :problem_objectives
  visio_resources :outputs
  visio_resources :indicators
  visio_resources :indicator_data
  visio_resources :budgets
  visio_resources :expenditures
  visio_resources :offices
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
  resource :admin_configuration, :controller => :admin_configuration do
    collection do
      get 'download_users'
    end
  end

  resources :strategies do
    member do
      get 'download'
      post 'globalize'
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

  resources :narratives do
    collection do
      get 'summarize' => 'narratives#summarize'
      post 'summarize' => 'narratives#summarize'
      get 'status/:token' => 'narratives#status'
      get 'total_characters' => 'narratives#total_characters'
      get 'download' => 'narratives#to_docx'
      post 'download' => 'narratives#to_docx'
      get 'search' => 'narratives#search'
      post 'search' => 'narratives#search'
    end
    post 'index', on: :collection
  end

  resources :populations do
    post 'index', on: :collection
  end

  root :to => 'application#index'
end
