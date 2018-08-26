Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Root
  root 'home#index'
  # End Root

  # Change language
  get '/change_language/:lang', to: 'settings#change_lang', as: 'change_language'
  # End Change language

  # Admin namespace
  namespace :admin do
    # Root
    root 'home#index'
    # End Root

    # Providers
    get '/providers', to: 'providers#index', as: 'providers'
    get '/provider/new', to: 'providers#new', as: 'new_provider'
    get '/provider/:id', to: 'providers#show', as: 'provider'
    get '/provider/:id/edit', to: 'providers#edit', as: 'edit_provider'
    get '/provider/:id/history', to: 'providers#history', as: 'history_provider'
    post '/providers', to: 'providers#create'
    patch '/provider/:id', to: 'providers#update', as: 'update_provider'
    patch '/providers/state/:id', to: 'providers#active_deactive', as: 'active_deactive_provider'
    # End Providers

    # Categories
    get '/categories', to: 'categories#index', as: 'categories'
    get '/category/new', to: 'categories#new', as: 'new_category'
    get '/category/:id', to: 'categories#show', as: 'category'
    get '/category/:id/edit', to: 'categories#edit', as: 'edit_category'
    get '/category/:id/history', to: 'categories#history', as: 'history_category'
    post '/categories', to: 'categories#create'
    patch '/category/:id', to: 'categories#update', as: 'update_category'
    patch '/categories/state/:id', to: 'categories#active_deactive', as: 'active_deactive_category'
    # End Categories

    # Products
    get '/products', to: 'products#index', as: 'products'
    get '/product/new', to: 'products#new', as: 'new_product'
    get '/product/:id', to: 'products#show', as: 'product'
    get '/product/:id/edit', to: 'products#edit', as: 'edit_product'
    get '/product/:id/history', to: 'products#history', as: 'history_product'
    post '/products', to: 'products#create'
    patch '/product/:id', to: 'products#update', as: 'update_product'
    patch '/products/state/:id', to: 'products#active_deactive', as: 'active_deactive_product'
    # End Products
  end
  # End Admin namespace

end
