class Admin::CostumersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout
  
  # Find costumers with Friendly_ID
  before_action :set_costumer, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find costumers with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_costumer
  # End Authentication

  # /costumers
  def index
    @costumers = Costumer.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Costumers with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @costumers.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "costumers-#{file_time}"
    template = "admin/costumers/index_pdf.html.haml"
    title_pdf = t("header.navigation.costumers")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Costumer.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # /costumer/new
  def new
    @costumer = Costumer.new
  end

  # /costumer/:id)
  def show
    # Costumer found by before_action

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "costumer-#{@costumer.slug}-#{file_time}"
    template = "admin/costumers/show_pdf.html.haml"
    title_pdf = t("activerecord.models.costumer")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @costumer, I18n.l(datetime), title_pdf)
      end
    end
  end

  # /costumer/:id/edit
  def edit
    # Costumer found by before_action
  end

  # /costumer/:id/history
  def history
    # Costumer found by before_action

    @history = @costumer.associated_audits
    @history.push(@costumer.audits)
  end

  # Create
  def create
    @costumer = Costumer.new(costumer_params)

    # Deleting blank spaces
    @costumer[:first_name] = @costumer[:first_name].strip
    @costumer[:last_name]= @costumer[:last_name].strip
    @costumer[:email] =  @costumer[:email].strip.downcase
    @costumer[:phone] = @costumer[:phone].strip
    @costumer[:address] = @costumer[:address].strip
    # End Deleting blank spaces

    # If record was saved
    if @costumer.save
      redirect_to [:admin, @costumer], notice: t("alerts.created", model: t("activerecord.models.costumer"))

      # If record was not saved
    else
      render :new
    end
  end

  # Update
  def update
    if @costumer.update(costumer_params)
      redirect_to [:admin, @costumer], notice: t("alerts.updated", model: t("activerecord.models.costumer"))

    else
      render :edit
    end
  end

  # Active
  def active
    if @costumer.update(state: true)
      redirect_to_back(true, admin_costumers_path, "costumer", "success")

    else
      redirect_to_back(true, admin_costumers_path, "costumer", "error")
    end
  end

  # Deactive
  def deactive
    if @costumer.update(state: false)
      redirect_to_back(false, admin_costumers_path, "costumer", "success")

    else
      redirect_to_back(false, admin_costumers_path, "costumer", "error")
    end
  end

  private

  # Set Costumer
  def set_costumer
    @costumer = Costumer.friendly.find(params[:id])

  rescue
    redirect_to admin_costumers_path, alert: t("alerts.not_found", model: t("activerecord.models.costumer"))
  end

  # Costumer params
  def costumer_params
    params.require(:costumer).permit(:first_name, :last_name, :email, :phone, :address, :image)
  end
end
