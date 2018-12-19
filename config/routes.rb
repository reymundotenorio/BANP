Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # Change language
  get "/change-language/:lang", to: "settings#change_lang", as: "change_language"
  # End Change language

  # Errors pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # Root
  root "landing#index"
  # End Root

  # Products
  get "/products", to: "products#index", as: "products"
  get "/product/:id", to: "products#show", as: "product"
  # End Products

  # Authentications

  # Notifications
  get "/authentication/notifications", to: "authentication/notifications#index", as: "auth_notifications"
  # End Notifications

  # Registrations
  get "/sign-up", to: "authentication/registrations#new", as: "sign_up"
  # End Registrations

  # Sessions
  get "/sign-in", to: "authentication/sessions#new", as: "sign_in"
  get "/two-factor", to: "authentication/sessions#two_factor", as: "two_factor"
  post "/sign-in", to: "authentication/sessions#create", as: "sign_in_costumer"
  post "/two-factor", to: "authentication/sessions#two_factor_auth", as: "two_factor_auth"
  patch "/resend-otp", to: "authentication/sessions#resend_otp", as: "resend_otp"
  delete "/sign-out", to: "authentication/sessions#destroy", as: "sign_out"
  # End Sessions

  # Confirmations
  get '/confirm-account', to: 'authentication/confirmations#new', as: 'confirm_account'
  get '/confirm-costumer-account/:confirmation_token', to: 'authentication/confirmations#show', as: 'confirm_costumer_account'
  post "/confirm-account", to: "authentication/confirmations#send_confirmation_email", as: "resend_confirmation"
  # End Confirmations

  # Unlocks
  get '/unlock-account', to: 'authentication/unlocks#new', as: 'unlock_account'
  get '/unlock-costumer-account/:unlock_token', to: 'authentication/unlocks#show', as: 'unlock_costumer_account'
  post "/unlock-account", to: "authentication/unlocks#send_unlock_email", as: "resend_unlock"
  # End Unlocks

  # Passwords
  get "/reset-password", to: "authentication/passwords#new", as: "reset_password"
  get "/reset-costumer-password/:reset_password_token", to: "authentication/passwords#show", as: "reset_costumer_password"
  post "/reset-password", to: "authentication/passwords#send_reset_password_email", as: "resend_reset_password"
  patch "/reset-costumer-password", to: "authentication/passwords#update_password", as: "update_password"
  # End Passwords

  # End Authentications

  # Charts namespace
  namespace :charts do
    get "product-by-category", to: "product_by_category", as: "product_by_category"
  end
  # End Charts namespace

  # Admin namespace
  namespace :admin, constraints: {subdomain: "admin"} do
    # Root
    root "dashboard#index"
    # End Root

    # Authentications

    # Notifications
    get "/authentication/notifications", to: "authentication/notifications#index", as: "auth_notifications"
    # End Notifications

    # Sessions
    get "/sign-in", to: "authentication/sessions#new", as: "sign_in"
    get "/two-factor", to: "authentication/sessions#two_factor", as: "two_factor"
    post "/sign-in", to: "authentication/sessions#create", as: "sign_in_employee"
    post "/two-factor", to: "authentication/sessions#two_factor_auth", as: "two_factor_auth"
    patch "/resend-otp", to: "authentication/sessions#resend_otp", as: "resend_otp"
    delete "/sign-out", to: "authentication/sessions#destroy", as: "sign_out"
    # End Sessions

    # Confirmations
    get '/confirm-account', to: 'authentication/confirmations#new', as: 'confirm_account'
    get '/confirm-employee-account/:confirmation_token', to: 'authentication/confirmations#show', as: 'confirm_employee_account'
    post "/confirm-account", to: "authentication/confirmations#send_confirmation_email", as: "resend_confirmation"
    # End Confirmations

    # Unlocks
    get '/unlock-account', to: 'authentication/unlocks#new', as: 'unlock_account'
    get '/unlock-employee-account/:unlock_token', to: 'authentication/unlocks#show', as: 'unlock_employee_account'
    post "/unlock-account", to: "authentication/unlocks#send_unlock_email", as: "resend_unlock"
    # End Unlocks

    # Passwords
    get "/reset-password", to: "authentication/passwords#new", as: "reset_password"
    get "/reset-employee-password/:reset_password_token", to: "authentication/passwords#show", as: "reset_employee_password"
    post "/reset-password", to: "authentication/passwords#send_reset_password_email", as: "resend_reset_password"
    patch "/reset-employee-password", to: "authentication/passwords#update_password", as: "update_password"
    # End Passwords

    # End Authentications

    # Employees
    get "/employees", to: "employees#index", as: "employees"
    get "/employee/new", to: "employees#new", as: "new_employee"
    get "/employee/:id", to: "employees#show", as: "employee"
    get "/employee/:id/edit", to: "employees#edit", as: "edit_employee"
    get "/employee/:id/history", to: "employees#history", as: "history_employee"
    post "/employees", to: "employees#create"
    patch "/employee/:id", to: "employees#update", as: "update_employee"
    patch "/employees/:id/active", to: "employees#active", as: "active_employee"
    patch "/employees/:id/deactive", to: "employees#deactive", as: "deactive_employee"
    # End Employees

    # Employees/Users
    get "/employee/:id/create-user", to: "users#new_employee_user", as: "new_employee_user"
    get "/employee/:id/update-password", to: "users#employee_update_password", as: "update_password_employee"
    post "/employee/:id/create-user", to: "users#create_employee_user", as: "create_employee_user"
    patch "/employee/:id/update-password", to: "users#employee_change_password", as: "change_password_employee"
    # End Employees/Users

    # Providers
    get "/providers", to: "providers#index", as: "providers"
    get "/provider/new", to: "providers#new", as: "new_provider"
    get "/provider/:id", to: "providers#show", as: "provider"
    get "/provider/:id/edit", to: "providers#edit", as: "edit_provider"
    get "/provider/:id/history", to: "providers#history", as: "history_provider"
    post "/providers", to: "providers#create"
    patch "/provider/:id", to: "providers#update", as: "update_provider"
    patch "/providers/:id/active", to: "providers#active", as: "active_provider"
    patch "/providers/:id/deactive", to: "providers#deactive", as: "deactive_provider"
    # End Providers

    # Costumers
    get "/costumers", to: "costumers#index", as: "costumers"
    get "/costumer/new", to: "costumers#new", as: "new_costumer"
    get "/costumer/:id", to: "costumers#show", as: "costumer"
    get "/costumer/:id/edit", to: "costumers#edit", as: "edit_costumer"
    get "/costumer/:id/history", to: "costumers#history", as: "history_costumer"
    post "/costumers", to: "costumers#create"
    patch "/costumer/:id", to: "costumers#update", as: "update_costumer"
    patch "/costumers/:id/active", to: "costumers#active", as: "active_costumer"
    patch "/costumers/:id/deactive", to: "costumers#deactive", as: "deactive_costumer"
    # End Costumers

    # Costumers/Users
    get "/costumer/:id/create-user", to: "users#new_costumer_user", as: "new_costumer_user"
    get "/costumer/:id/update-password", to: "users#costumer_update_password", as: "update_password_costumer"
    post "/costumer/:id/create-user", to: "users#create_costumer_user", as: "create_costumer_user"
    patch "/costumer/:id/update-password", to: "users#costumer_change_password", as: "change_password_costumer"
    # End Costumers/Users

    # Categories
    get "/categories", to: "categories#index", as: "categories"
    get "/category/new", to: "categories#new", as: "new_category"
    get "/category/:id", to: "categories#show", as: "category"
    get "/category/:id/edit", to: "categories#edit", as: "edit_category"
    get "/category/:id/history", to: "categories#history", as: "history_category"
    post "/categories", to: "categories#create"
    patch "/category/:id", to: "categories#update", as: "update_category"
    patch "/categories/:id/active", to: "categories#active", as: "active_category"
    patch "/categories/:id/deactive", to: "categories#deactive", as: "deactive_category"
    # End Categories

    # Products
    get "/products", to: "products#index", as: "products"
    get "/product/new", to: "products#new", as: "new_product"
    get "/product/:id", to: "products#show", as: "product"
    get "/product/:id/edit", to: "products#edit", as: "edit_product"
    get "/product/:id/history", to: "products#history", as: "history_product"
    post "/products", to: "products#create"
    patch "/product/:id", to: "products#update", as: "update_product"
    patch "/products/:id/active", to: "products#active", as: "active_product"
    patch "/products/:id/deactive", to: "products#deactive", as: "deactive_product"
    # End Products
  end
  # End Admin namespace

end
