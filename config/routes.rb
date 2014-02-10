Visio::Application.routes.draw do
  #devise_for :users, :controllers => {:sessions => 'sessions', :registrations => 'registrations' }
  devise_for :users

  # Application
  get '/splash' => 'application#splash'
  get '/algorithms' => 'application#algorithms'
  get '/map' => 'application#map'
  get '/overview' => 'application#overview'
  get '/global_search' => 'application#global_search'

  # CMS
  get '/cms/strategies' => 'cms#strategies'

  # Resources
  syncable_resources :operations
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
  resources :export_modules do
    member do
      get 'pdf'
    end
  end
  resources :strategy_objectives
  resources :strategies
  resources :users

  root :to => 'application#index'
end
