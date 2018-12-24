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
    @customer.build_user
  end

  # /customer/:id)
  def show
    # Customer found by before_action
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
    params.require(:customer).permit(:first_name, :last_name, :company, :email, :phone, :address, :image, user_attributes: [:email, :password, :password_confirmation, :two_factor_auth])
  end
end
