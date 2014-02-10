Transiterm::Application.routes.draw do
  root to: 'pages#home'
  get 'msaccess' => 'pages#msaccess', as: :msaccess
  get 'home' => 'pages#home', as: :home

  resources :users, except: [:index, :show] do
    member do
      get :activate
      get :unlock
    end
  end
  get 'user_lang_toggle' => 'users#lang_toggle', as: :lang_toggle
  get 'collection_toggle' => 'users#collection_toggle', as: :collection_toggle

  resources :collections, except: [:index, :show]

  resources :term_records, except: [:index, :show]

  resources :password_resets, only: [:create, :edit, :update, :new]

  resources :sessions, only: [:create]
  get 'login' => 'sessions#new', as: :login
  post 'logout' => 'sessions#destroy', as: :logout

  get 'query' => 'queries#show', as: :query

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
