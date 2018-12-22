class CustomersController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Find customers with Friendly_ID
  before_action :set_customer, only: [:show, :edit, :update, :deactive]
  # End Find customers with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active]
  # End Sync model DSL

  # Authentication
  # before_action :require_customer
  # End Authentication

  # /customer/new
  def new
    @customer = Customer.new
  end

  # /customer/:id)
  def show
    # Customer found by before_action

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "customer-#{@customer.slug}-#{file_time}"
    template = "admin/customers/show_pdf.html.haml"
    title_pdf = t("activerecord.models.customer")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @customer, I18n.l(datetime), title_pdf)
      end
    end
  end

  # /customer/:id/edit
  def edit
    # Customer found by before_action
  end

  # Create
  def create
    @customer = Customer.new(customer_params)

    # Deleting blank spaces
    @customer[:first_name] = @customer[:first_name].strip
    @customer[:last_name]= @customer[:last_name].strip
    @customer[:email] =  @customer[:email].strip.downcase
    @customer[:phone] = @customer[:phone].strip
    @customer[:address] = @customer[:address].strip
    # End Deleting blank spaces

    # If record was saved
    if @customer.save
      redirect_to @customer, notice: t("alerts.created", model: t("activerecord.models.customer"))

      # If record was not saved
    else
      render :new
    end
  end

  # Update
  def update
    if @customer.update(customer_params)
      redirect_to @customer, notice: t("alerts.updated", model: t("activerecord.models.customer"))

    else
      render :edit
    end
  end

  # Deactive
  def deactive
    if @customer.update(state: false)
      redirect_to_back(false, customer_path(@customer), "customer", "success")

    else
      redirect_to_back(false, customer_path(@customer), "customer", "error")
    end
  end

  private

  # Set Customer
  def set_customer
    @customer = Customer.friendly.find(params[:id])

  rescue
    redirect_to customer_path(@customer), alert: t("alerts.not_found", model: t("activerecord.models.customer"))
  end

  # Customer params
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :phone, :address, :image)
  end
end
