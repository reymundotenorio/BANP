class Admin::ReportsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee
  # End Authentication

  def sales
    @search_form_path = admin_create_reports_sales_path(@invoice)

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
  end
  
  def sales_report
    puts "#{params}".red

    if from_datetime
    end

    if to_datetime
    end

    if report_customer_id
    end

    if report_product_id
    end



  end

  def purchases
  end
end
