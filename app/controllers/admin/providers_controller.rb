class Admin::ProvidersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find providers with Friendly_ID
  before_action :set_provider, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find providers with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # admin/providers
  def index
    @providers = Provider.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Providers with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @providers.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "providers-#{file_time}"
    template = "admin/providers/index_pdf.html.haml"
    title_pdf = t("header.navigation.providers")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Provider.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/provider/new
  def new
    @provider = Provider.new
  end

  # admin/provider/:id)
  def show
    # Provider found by before_action

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "provider-#{@provider.slug}-#{file_time}"
    template = "admin/providers/show_pdf.html.haml"
    title_pdf = t("activerecord.models.provider")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @provider, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/provider/:id/edit
  def edit
    # Provider found by before_action
  end

  # admin/provider/:id/history
  def history
    # Provider found by before_action

    @history = @provider.audits
  end

  # Create
  def create
    @provider = Provider.new(provider_params)

    # Deleting blank spaces
    @provider[:name] = @provider[:name].strip
    @provider[:FEIN]= @provider[:FEIN].strip
    @provider[:email] =  @provider[:email].strip.downcase
    @provider[:phone] = @provider[:phone].strip
    @provider[:address] = @provider[:address].strip
    # End Deleting blank spaces

    # If record was saved
    if @provider.save
      redirect_to [:admin, @provider], notice: t("alerts.created", model: t("activerecord.models.provider"))

      # If record was not saved
    else
      render :new
    end
  end

  # Update
  def update
    if @provider.update(provider_params)
      redirect_to [:admin, @provider], notice: t("alerts.updated", model: t("activerecord.models.provider"))

    else
      render :edit
    end
  end

  # Active
  def active
    if @provider.update(state: true)
      redirect_to_back(true, admin_providers_path, "provider", "success")

    else
      redirect_to_back(true, admin_providers_path, "provider", "error")
    end
  end

  # Deactive
  def deactive
    if @provider.update(state: false)
      redirect_to_back(false, admin_providers_path, "provider", "success")

    else
      redirect_to_back(false, admin_providers_path, "provider", "error")
    end
  end

  private

  # Set Provider
  def set_provider
    @provider = Provider.friendly.find(params[:id])

  rescue
    redirect_to admin_providers_path, alert: t("alerts.not_found", model: t("activerecord.models.provider"))
  end

  # Provider params
  def provider_params
    params.require(:provider).permit(:name, :FEIN, :email, :phone, :address, :image)
  end
end
