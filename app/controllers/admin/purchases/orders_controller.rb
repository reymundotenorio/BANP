class Admin::Purchases::OrdersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find purchase order with Friendly_ID
  before_action :set_purchase_order, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find purchase order with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # /admin/purchases/orders
  def index
    @orders = Purchase.search_order(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @orders.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchase-orders-#{file_time}"
    template = "admin/purchases/orders/index_pdf.html.haml"
    title_pdf = t("purchase.orders")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Purchase.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/purchases/order/new
  def new
    @order = Purchase.new
    @order.discount = 0
    @order.receipt_number = "N/A"

    @search_form_path = admin_new_purchase_order_path(@order)
    @form_url = admin_purchases_order_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/order/:id/edit
  def edit
    # Order found by before_action
    @order.discount = "%.2f" % @order.discount
    @order.discount = "0#{@order.discount.to_s.gsub! '.', ''}" if @order.discount < 10

    @search_form_path = admin_edit_product_path(@order)
    @form_url = admin_update_purchase_order_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/order/:id/history
  def history
    # Employee found by before_action

    @history = @order.associated_audits
    @history.push(@order.audits)
  end

  # Create
  def create
    @order = Purchase.new(purchase_order_params)

    # Deleting blank spaces
    @order[:receipt_number] = @order[:receipt_number].strip
    @order[:status] = "ordered"
    @order[:observations] = @order[:observations].strip
    # End Deleting blank spaces

    @order[:purchase_datetime] = @order[:purchase_datetime].to_datetime if @order[:purchase_datetime]

    # Fixing discount
    if @order[:discount]
      begin
        @order[:discount] = @order[:discount].to_d

      rescue
        @order[:discount] = 0.00
      end
    end

    # If record was saved
    if @order.save
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.created", model: t("purchase.order"))

      # If record was not saved
    else
      @search_form_path = admin_new_purchase_order_path(@order)
      @form_url = admin_purchases_order_path

      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      render :new
    end
  end

  # Update
  def update
    updated_params = purchase_order_params

    # Deleting blank spaces
    updated_params[:receipt_number] = updated_params[:receipt_number].strip
    updated_params[:status] = "ordered"
    updated_params[:observations] = updated_params[:observations].strip
    # End Deleting blank spaces

    updated_params[:purchase_datetime] = updated_params[:purchase_datetime].to_datetime if updated_params[:purchase_datetime]

    # Fixing discount
    if updated_params[:discount]
      begin
        updated_params[:discount] = updated_params[:discount].to_d

      rescue
        updated_params[:discount] = 0.00
      end
    end

    if @order.update(updated_params)
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.updated", model: t("purchase.order"))

    else
      @search_form_path = admin_edit_product_path(@order)
      @form_url = admin_update_purchase_order_path

      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      render :edit
    end
  end

  # Active
  def active
    if @order.update(state: true)
      redirect_to_back(true, admin_purchase_orders_path, "purchase", "success")

    else
      redirect_to_back(true, admin_purchase_orders_path, "purchase", "error")
    end
  end

  # Deactive
  def deactive
    if @order.update(state: false)
      redirect_to_back(false, admin_purchase_orders_path, "purchase", "success")

    else
      redirect_to_back(false, admin_purchase_orders_path, "purchase", "error")
    end
  end

  private

  # Set Purchase
  def set_purchase_order
    @order = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_orders_path, alert: t("alerts.not_found", model: t("purchase.order"))
  end

  def purchase_order_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
