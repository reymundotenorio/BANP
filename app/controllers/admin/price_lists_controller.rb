class Admin::PriceListsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee, :require_seller
  # End Authentication

  # /admin/sales/price-lists
  def index
    @price_lists = Sale.search_price_list(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @price_lists.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "price-lists-#{file_time}"
    template = "admin/price_lists/index_pdf.html.haml"
    title_pdf = t("sale.price_lists")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Sale.price_lists, I18n.l(datetime), title_pdf)
      end
    end
  end

  def new
    @price_list = Sale.new
    @price_list.discount = 0

    @search_form_path = admin_new_price_list_path(@price_list)
    @form_url = admin_price_list_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # Create
  def create
    @price_list = Sale.new(price_list_params)

    @price_list[:delivery_status] = "received"
    @price_list[:status] = "price_list"

    @price_list[:payment_method] = "cash"
    @price_list[:payment_reference] = "*****"
    @price_list[:paid] = false

    # Deleting blank spaces
    @price_list[:observations] = @price_list[:observations].strip
    # End Deleting blank spaces

    @price_list[:sale_datetime] = @price_list[:sale_datetime].to_datetime if @price_list[:sale_datetime]

    # Fixing discount
    if @price_list[:discount]
      begin
        @price_list[:discount] = @price_list[:discount].to_d

      rescue
        @price_list[:discount] = 0.00
      end
    end

    # If record was saved
    if @price_list.save
      redirect_to admin_sale_details_path(@price_list.id), notice: t("alerts.created", model: t("sale.price_list"))

      # If record was not saved
    else
      @search_form_path = admin_new_price_list_path(@price_list)
      @form_url = admin_price_list_path

      @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      # render :new_price_list

      respond_to do |format|
        format.html
        format.js
      end
    end
  end

  private

  def price_list_params
    params.require(:sale).permit(:sale_datetime, :status, :delivery_status, :payment_method, :payment_reference, :paid, :discount, :customer_id, :employee_id, :observations, sale_details_attributes: SaleDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
