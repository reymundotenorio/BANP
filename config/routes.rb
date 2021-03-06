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

  # Cart
  get "/cart", to: "cart#index", as: "cart"
  # End Cart

  # Stripe
  get "/stripe/checkout", to: "stripe#payment", as: "stripe_payment"
  post "/stripe/checkout", to: "stripe#checkout", as: "stripe_checkout"
  # End Stripe

  # PayPal
  get "/paypal/payment", to: "paypal#paypal_payment", as: "paypal_payment"
  get "/paypal/sign-in", to: "paypal#paypal_sign_in", as: "paypal_sign_in"
  get "/paypal/checkout", to: "paypal#paypal_order", as: "paypal_order"
  post "/paypal/checkout", to: "paypal#paypal_checkout", as: "paypal_checkout"
  post "/paypal/sign-in", to: "paypal#paypal_auth", as: "paypal_auth"
  # End PayPal

  # Pay upon delivery
  get "/pay-upon-delivery/checkout", to: "pay_upon_delivery#payment", as: "pay_upon_delivery_payment"
  post "/pay-upon-delivery/checkout", to: "pay_upon_delivery#checkout", as: "pay_upon_delivery_checkout"
  # End Pay upon delivery

  # Notifications
  get "/authentication/notifications", to: "authentication/notifications#index", as: "auth_notifications"
  # End Notifications

  # Customers
  get "/sign-up", to: "customers#new", as: "sign_up"
  get "/user", to: "customers#show", as: "customer"
  get "/user/edit", to: "customers#edit", as: "edit_customer"
  get "/users", to: redirect("/sign-up")
  post "/users", to: "customers#create", as: "customers"
  patch "/user", to: "customers#update", as: "update_customer"
  patch "/user/deactive", to: "customers#deactive", as: "deactive_customer"
  # End Customers

  # Users
  get "/user/update-password", to: "users#customer_update_password", as: "customer_update_password"
  patch "/user/update-password", to: "users#customer_change_password", as: "customer_change_password"
  # End Users

  # Sessions
  get "/sign-in", to: "authentication/sessions#new", as: "sign_in"
  get "/two-factor", to: "authentication/sessions#two_factor", as: "two_factor"
  post "/sign-in", to: "authentication/sessions#create", as: "sign_in_customer"
  post "/two-factor", to: "authentication/sessions#two_factor_auth", as: "two_factor_auth"
  patch "/resend-otp", to: "authentication/sessions#resend_otp", as: "resend_otp"
  delete "/sign-out", to: "authentication/sessions#destroy", as: "sign_out"
  # End Sessions

  # Confirmations
  get "/confirm-account", to: "authentication/confirmations#new", as: "confirm_account"
  get "/confirm-customer-account/:confirmation_token", to: "authentication/confirmations#show", as: "confirm_customer_account"
  post "/confirm-account", to: "authentication/confirmations#send_confirmation_email", as: "resend_confirmation"
  # End Confirmations

  # Unlocks
  get "/unlock-account", to: "authentication/unlocks#new", as: "unlock_account"
  get "/unlock-customer-account/:unlock_token", to: "authentication/unlocks#show", as: "unlock_customer_account"
  post "/unlock-account", to: "authentication/unlocks#send_unlock_email", as: "resend_unlock"
  # End Unlocks

  # Passwords
  get "/reset-password", to: "authentication/passwords#new", as: "reset_password"
  get "/reset-customer-password/:reset_password_token", to: "authentication/passwords#show", as: "reset_customer_password"
  post "/reset-password", to: "authentication/passwords#send_reset_password_email", as: "resend_reset_password"
  patch "/reset-customer-password", to: "authentication/passwords#update_password", as: "update_password"
  # End Passwords

  # End Authentications

  # Trackings
  get "/orders", to: "trackings#index", as: "orders"
  get "/tracking/:id", to: "trackings#show", as: "tracking"
  patch "/tracking/:id/confirm", to: "trackings#confirm_delivery", as: "confirm_delivery"
  # End Trackings

  # Invoices
  get "/invoice/:id", to: "invoices#show", as: "order_invoice"
  # End Invoices

  # Charts namespace
  namespace :charts do
    get "purchases-by-month", to: "purchases_by_month", as: "purchases_by_month"
    get "sales-by-month", to: "sales_by_month", as: "sales_by_month"

    get "sales-by-products", to: "sales_by_products", as: "sales_by_products"
    get "purchases-by-products", to: "purchases_by_products", as: "purchases_by_products"

    get "sales-by-customers", to: "sales_by_customers", as: "sales_by_customers"
    get "purchases-by-providers", to: "purchases_by_providers", as: "purchases_by_providers"

    get "sales-by-employees", to: "sales_by_employees", as: "sales_by_employees"
    get "purchases-by-employees", to: "purchases_by_employees", as: "purchases_by_employees"

    get "sales-by-categories", to: "sales_by_categories", as: "sales_by_categories"
    get "purchases-by-categories", to: "purchases_by_categories", as: "purchases_by_categories"

    get "products-by-categories", to: "products_by_categories", as: "products_by_categories"
  end
  # End Charts namespace

  # Admin namespace
  namespace :admin do
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
    get "/confirm-account", to: "authentication/confirmations#new", as: "confirm_account"
    get "/confirm-employee-account/:confirmation_token", to: "authentication/confirmations#show", as: "confirm_employee_account"
    post "/confirm-account", to: "authentication/confirmations#send_confirmation_email", as: "resend_confirmation"
    # End Confirmations

    # Unlocks
    get "/unlock-account", to: "authentication/unlocks#new", as: "unlock_account"
    get "/unlock-employee-account/:unlock_token", to: "authentication/unlocks#show", as: "unlock_employee_account"
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

    # Customers
    get "/customers", to: "customers#index", as: "customers"
    get "/customer/new", to: "customers#new", as: "new_customer"
    get "/customer/:id", to: "customers#show", as: "customer"
    get "/customer/:id/edit", to: "customers#edit", as: "edit_customer"
    get "/customer/:id/history", to: "customers#history", as: "history_customer"
    post "/customers", to: "customers#create"
    patch "/customer/:id", to: "customers#update", as: "update_customer"
    patch "/customers/:id/active", to: "customers#active", as: "active_customer"
    patch "/customers/:id/deactive", to: "customers#deactive", as: "deactive_customer"
    # End Customers

    # Customers/Users
    get "/customer/:id/create-user", to: "users#new_customer_user", as: "new_customer_user"
    get "/customer/:id/update-password", to: "users#customer_update_password", as: "update_password_customer"
    post "/customer/:id/create-user", to: "users#create_customer_user", as: "create_customer_user"
    patch "/customer/:id/update-password", to: "users#customer_change_password", as: "change_password_customer"
    # End Customers/Users

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

    # Purchases orders
    get "/purchases/orders", to: "purchases#index_orders", as: "purchase_orders"
    get "/purchases/order/new", to: "purchases#new_order", as: "new_purchase_order"
    get "/purchases/order/:id/edit", to: "purchases#edit_order", as: "edit_purchase_order"
    get "/purchases/order/:id/history", to: "purchases#history_order", as: "history_purchase_order"
    post "/purchases/order", to: "purchases#create_order", as: "purchase_order"
    patch "/purchases/order/:id", to: "purchases#update_order", as: "update_purchase_order"
    patch "/purchases/order/:id/active", to: "purchases#active_order", as: "active_purchase_order"
    patch "/purchases/order/:id/deactive", to: "purchases#deactive_order", as: "deactive_purchase_order"
    # End Purchases orders

    # Purchases receptions
    get "/purchases/receptions", to: "purchases#index_receptions", as: "purchase_receptions"
    get "/purchases/reception/:id/new", to: "purchases#new_reception", as: "new_purchase_reception"
    get "/purchases/reception/:id/edit", to: "purchases#edit_reception", as: "edit_purchase_reception"
    get "/purchases/reception/:id/history", to: "purchases#history_reception", as: "history_purchase_reception"
    patch "/purchases/reception/:id", to: "purchases#create_reception", as: "purchases_reception"
    patch "/purchases/reception/:id/active", to: "purchases#active_reception", as: "active_purchase_reception"
    patch "/purchases/reception/:id/deactive", to: "purchases#deactive_reception", as: "deactive_purchase_reception"
    # End Purchases receptions

    # Purchases returns and loss
    get "/purchases/returns", to: "purchases#index_returns", as: "purchase_returns"
    get "/purchases/reception/:id/return", to: "purchases#new_return", as: "new_purchase_return"
    get "/purchases/reception/:id/loss", to: "purchases#new_loss", as: "new_purchase_loss"
    patch "/purchases/reception/return/:id", to: "purchases#create_return", as: "purchase_return"
    patch "/purchases/reception/loss/:id", to: "purchases#create_loss", as: "purchase_loss"
    # End Purchases returns and loss

    # Purchases details
    get "/purchases/:id/details", to: "purchase_details#show", as: "purchase_details"
    get "/purchase/detail/:id/edit", to: "purchase_details#edit", as: "edit_purchase_detail"
    get "/purchase/detail/:id/history", to: "purchase_details#history", as: "history_purchase_detail"
    patch "/purchases/detail/:id", to: "purchase_details#update", as: "update_purchase_detail"
    # End Purchases details

    # Inventory
    get "/inventory", to: "products#inventory_index", as: "inventory"
    # End Inventory

    # Sales orders
    get "/sales/orders", to: "sales#index_orders", as: "sale_orders"
    get "/sales/order/:id/history", to: "sales#history_order", as: "history_sale_order"
    # End Sales orders

    # Sales invoices
    get "/sales/invoices", to: "sales#index_invoices", as: "sale_invoices"
    get "/sales/invoice/new", to: "sales#new_invoice", as: "new_sale_invoice"
    get "/sales/invoice/:id/edit", to: "sales#edit_invoice", as: "edit_sale_invoice"
    get "/sales/invoice/:id/history", to: "sales#history_invoice", as: "history_sale_invoice"
    post "/sales/invoice", to: "sales#create_invoice", as: "sale_invoice"
    patch "/sales/invoice/:id", to: "sales#update_invoice", as: "update_sale_invoice"
    patch "/sales/invoice/:id/deactive", to: "sales#deactive_invoice", as: "deactive_sale_invoice"
    # End Sales invoices

    # Sales shipments
    get "/sales/shipments", to: "sales#index_shipments", as: "sale_shipments"
    get "/sales/shipment/:id/history", to: "sales#history_shipment", as: "history_sale_shipment"
    patch "/sales/shipment/:id/new", to: "sales#new_shipment", as: "new_sale_shipment"
    # End Sales shipments

    # Sales deliveries
    get "/sales/deliveries", to: "sales#index_deliveries", as: "sale_deliveries"
    get "/sales/delivery/:id/edit", to: "sales#edit_delivery", as: "edit_sale_delivery"
    get "/sales/delivery/:id/history", to: "sales#history_delivery", as: "history_sale_delivery"
    patch "/sales/delivery/:id/new", to: "sales#new_delivery", as: "new_sale_delivery"
    patch "/sales/delivery/:id", to: "sales#update_delivery", as: "update_sale_delivery"
    patch "/sales/delivery/:id/deactive", to: "sales#deactive_delivery", as: "deactive_sale_delivery"
    # End Sales deliveries

    # sales returns
    get "/sales/returns", to: "sales#index_returns", as: "sale_returns"
    get "/sales/invoice/:id/return", to: "sales#new_invoice_return", as: "new_sale_invoice_return"
    get "/sales/delivery/:id/return", to: "sales#new_delivery_return", as: "new_sale_delivery_return"
    patch "/sales/invoice/return/:id", to: "sales#create_invoice_return", as: "sale_invoice_return"
    patch "/sales/delivery/return/:id", to: "sales#create_delivery_return", as: "sale_delivery_return"
    # End sales returns

    # Price lists
    get "/price-lists", to: "price_lists#index", as: "price_lists"
    get "/price-lists/new", to: "price_lists#new", as: "new_price_list"
    post "/price-lists", to: "price_lists#create", as: "price_list"
    # End Price lists

    # Sales details
    get "/sales/:id/details", to: "sale_details#show", as: "sale_details"
    get "/sale/detail/:id/edit", to: "sale_details#edit", as: "edit_sale_detail"
    get "/sale/detail/:id/history", to: "sale_details#history", as: "history_sale_detail"
    patch "/sales/detail/:id", to: "sale_details#update", as: "update_sale_detail"
    # End Sales details

    # Reports
    get "/reports/purchases", to: "reports#purchases", as: "reports_purchases"
    get "/reports/sales", to: "reports#sales", as: "reports_sales"
    get "/reports/purchases_results", to: "reports#purchases_report", as: "create_reports_purchases"
    get "/reports/sales_results", to: "reports#sales_report", as: "create_reports_sales"
    # End Reports

    # Notifications
    get "/notification/:id", to: "notifications#notification_redirect", as: "notification_redirect"
    patch "/notifications/clean", to: "notifications#clean_notifications", as: "clean_notifications"
    # End Notifications
  end
  # End Admin namespace

end
