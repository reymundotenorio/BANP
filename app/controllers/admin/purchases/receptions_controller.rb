class Admin::Purchases::ReceptionsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find purchase reception with Friendly_ID
  before_action :set_purchase_reception, only: [:new, :show, :edit, :create, :active, :deactive, :history]
  # End Find purchase reception with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # /admin/purchases/receptions
  def index
    @receptions = Purchase.search_reception(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @receptions.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchase-receptions-#{file_time}"
    template = "admin/purchase_receptions/index_pdf.html.haml"
    title_pdf = t("purchase.receptions")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Purchase.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/purchases/reception/new
  def new
    @search_form_path = admin_new_purchase_reception_path(@reception)
    @form_url = admin_purchases_reception_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/reception/:id/edit
  def edit
    # Order found by before_action
    @reception.discount = "%.2f" % @reception.discount
    @reception.discount = "0#{@reception.discount.to_s.gsub! '.', ''}" if @reception.discount < 10

    @search_form_path = admin_edit_product_path(@reception)
    @form_url = admin_purchases_reception_path
    # @form_url = admin_update_purchase_reception_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/reception/:id/history
  def history
    # Employee found by before_action

    @history = @reception.associated_audits
    @history.push(@reception.audits)
  end

  # Create
  def create
    # Deleting blank spaces
    @reception[:receipt_number]= @reception[:receipt_number].strip
    @reception[:status] = @reception[:status].strip
    @reception[:observations] = @reception[:observations].strip
    # End Deleting blank spaces

    @reception[:purchase_datetime] = @reception[:purchase_datetime].to_datetime if @reception[:purchase_datetime]

    # Fixing discount
    if @reception[:discount]
      begin
        @reception[:discount] = @reception[:discount].to_d

      rescue
        @reception[:discount] = 0.00
      end
    end

    # If record was saved
    if @reception.update(purchase_reception_params)
      redirect_to admin_purchase_details_path(@reception.id), notice: t("alerts.updated", model: t("purchase.reception")) # Received

      # If record was not saved
    else
      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      render :new
    end
  end

  # Update
  def update
    # Deleting blank spaces
    @reception[:receipt_number]= @reception[:receipt_number].strip
    @reception[:status] = "received"
    @reception[:observations] = @reception[:observations].strip
    # End Deleting blank spaces

    @reception[:purchase_datetime] = @reception[:purchase_datetime].to_datetime if @reception[:purchase_datetime]

    # Fixing discount
    if @reception[:discount]
      begin
        @reception[:discount] = @reception[:discount].to_d

      rescue
        @reception[:discount] = 0.00
      end
    end

    if @reception.update(purchase_reception_params)
      redirect_to admin_purchase_details_path(@reception.id), notice: t("alerts.updated", model: t("purchase.reception"))

    else
      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      render :edit
    end
  end

  # Active
  def active
    if @reception.update(state: true)
      redirect_to_back(true, admin_purchase_receptions_path, "purchase", "success")

    else
      redirect_to_back(true, admin_purchase_receptions_path, "purchase", "error")
    end
  end

  # Deactive
  def deactive
    if @reception.update(state: false)
      redirect_to_back(false, admin_purchase_receptions_path, "purchase", "success")

    else
      redirect_to_back(false, admin_purchase_receptions_path, "purchase", "error")
    end
  end

  private

  # Set Purchase
  def set_purchase_reception
    @reception = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_receptions_path, alert: t("alerts.not_found", model: t("purchase.reception"))
  end

  def purchase_reception_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
