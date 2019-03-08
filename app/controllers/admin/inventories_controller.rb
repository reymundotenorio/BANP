class Admin::InventoriesController < ApplicationController
 # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee, :require_seller_warehouse_supervisor
  # End Authentication

  # admin/products
  def index
    @products = Product.search_inventory(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Products with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @products.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "inventory-#{file_time}"
    template = "admin/inventories/index_pdf.html.haml"
    title_pdf = t("header.navigation.inventory")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Product.available, I18n.l(datetime), title_pdf)
      end
    end
  end
end
