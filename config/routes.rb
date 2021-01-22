# frozen_string_literal: true

Rails.application.routes.draw do
  concern :change_status do
    patch 'activate', on: :member
    patch 'deactivate', on: :member
  end

  concern :auditable do |options|
    scope module: options[:parent] do
      resources :audits, only: [:index]
    end
  end

  resources :location_types do
    scope module: :location_types do
      resources :locations, only: [:index]
    end

    concerns :auditable, parent: :location_types
  end

  resources :locations do
    resources :prints, only: [:new, :create]

    concerns :change_status
    concerns :auditable, parent: :locations
    scope module: :locations do
      resources :children, only: [:index]
      resources :labwares, only: [:index]
    end

  end

  resources :labwares, only: [:show] do
    concerns :auditable, parent: :labwares
  end

  resources :scans, only: [:new, :create]

  resources :upload_labware, only: [:new, :create]
  resources :move_locations, only: [:new, :create]
  resources :empty_locations, only: [:new, :create]
  resources :location_finder, only: [:new, :create]
  resources :searches, only: [:new, :create, :show]

  resources :users do
    concerns :auditable, parent: :users
    concerns :change_status
  end

  resources :teams do
    concerns :auditable, parent: :teams
  end

  resources :printers do
    concerns :auditable, parent: :printers
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'scans#new'

  namespace :api do
    get 'docs', to: 'docs#index'
    post 'labwares/searches', to: 'labwares/searches#create'
    post 'labwares/locations', to: 'labwares/locations#create'

    # This needs to be a post due to the number of barcodes that will be passed which is not possible with a get
    post 'labwares_by_barcode', to: 'labwares#by_barcode'
    root 'docs#index'

    put 'coordinates', to: 'coordinates#update'

    resources :locations, param: :barcode, except: [:destroy] do
      scope module: :locations do
        resources :labwares, only: [:index]
        resources :children, only: [:index]
        resources :descendants, only: [:index]
        resources :coordinates, only: [:index, :update]
      end

      concerns :auditable, parent: :locations
    end

    resources :location_types, except: [:destroy] do
      scope module: :location_types do
        resources :locations, only: [:index]
      end

      concerns :auditable, parent: :location_types
    end

    resources :scans, only: [:create]

    resources :labwares, param: :barcode, only: [:show, :index] do
      concerns :auditable, parent: :labwares
    end

    resources :searches, only: [:create]
  end

  unless Rails.env.development?
    match '(errors)/:status', to: 'errors#show', constraints: { status: /\d{3}/ }, via: :all
  end

  match 'test_exception_notifier', controller: 'application', action: 'test_exception_notifier', via: :get

  match '/about', to: 'about#show', via: :get

  
  
end
