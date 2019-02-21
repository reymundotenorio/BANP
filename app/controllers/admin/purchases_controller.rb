class Admin::PurchasesController < ApplicationController
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
    template = "admin/purchase_orders/index_pdf.html.haml"
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
    @search_form_path = admin_new_purchase_path(@order)
    @providers = Provider.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 5) # Providers with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/order/:id/edit
  def edit
    # Order found by before_action

    @search_form_path = admin_edit_product_path(@order)
    @providers = Provider.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 5) # Providers with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # Create
  def create
    @order = Purchase.new(purchase_order_params)

    # Deleting blank spaces
    @order[:receipt_number]= @order[:receipt_number].strip
    @order[:status] = @order[:status].strip
    @order[:observations] = @order[:observations].strip
    # End Deleting blank spaces

    @order[:purchase_datetime] = @order[:purchase_datetime].to_datetime

    # Fixing price
    # if @order[:price]
    #   begin
    #     price = @order[:price].remove(",")
    #     @order[:price] = price.to_d
    #
    #   rescue
    #     @order[:price] = 0.00
    #   end
    # end

    # If record was saved
    if @order.save
      redirect_to [:admin, @order], notice: t("alerts.created", model: t("purchase.order"))

      # If record was not saved
    else
      @providers = Provider.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 5) # Providers
      render :new
    end
  end

  # Update
  def update
    updated_params = purchase_order_params

    # Fixing price
    # if updated_params[:price]
    #   begin
    #     price = updated_params[:price].remove(",")
    #     updated_params[:price] = price.to_d
    #
    #   rescue
    #     updated_params[:price] = 0.00
    #   end
    # end

    if @order.update(updated_params)
      redirect_to [:admin, @order], notice: t("alerts.updated", model: t("purchase.order"))

    else
      @providers = Provider.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 5) # Providers with pagination
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
    @order = Purchase.friendly.find(params[:id])

  rescue
    redirect_to admin_purchase_orders_path, alert: t("alerts.not_found", model: t("activerecord.models.purchase_order"))
  end

  def purchase_order_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
