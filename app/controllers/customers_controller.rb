class CustomersController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Find customers with Friendly_ID
  before_action :set_customer, only: [:show, :edit, :update, :deactive]
  # End Find customers with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :deactive, :send_confirmation_email]
  # End Sync model DSL

  # Authentication
  # before_action :require_customer
  # End Authentication

  # /user/new
  def new
    @customer = Customer.new
    @customer.build_user

    @form_url = customers_path
  end

  # /user)
  def show
    # Customer found by before_action
  end

  # /user/edit
  def edit
    # Customer found by before_action

    @form_url = update_customer_path
  end

  # Create
  def create
    @customer = Customer.new(customer_params)

    # Verify recaptcha
    if !verify_recaptcha
      # redirect_to sign_up_path, alert: t("views.form.recaptcha_error")
      flash.now[:alert] = t("views.form.recaptcha_error")
      render :new
      return
    end

    # Deleting blank spaces
    @customer[:first_name] = @customer[:first_name].strip
    @customer[:last_name] = @customer[:last_name].strip
    @customer[:email] =  @customer[:email].strip.downcase
    @customer[:phone] = @customer[:phone].strip
    @customer[:zipcode] = @customer[:zipcode].strip
    @customer[:address] = @customer[:address].strip
    # End Deleting blank spaces

    # If record was saved
    if @customer.save
      send_confirmation_email
      redirect_to auth_notifications_path(source: "sign-up"), notice: "#{t('views.authentication.account_created_successfully')}. #{t('views.authentication.account_not_confirmed', email: @customer.email)}"

      # If record was not saved
    else
      @form_url = customers_path
      render :new
    end
  end

  # Update
  def update
    if @customer.update(customer_params)
      redirect_to customer_path, notice: t("alerts.updated", model: t("activerecord.models.user"))

    else
      @form_url = update_customer_path
      render :edit
    end
  end

  # Deactive #Pending on view
  def deactive
    if @customer.update(state: false)
      session[:customer_id] = nil
      session[:session_confirmed] = nil

      redirect_to sign_in_path, notice: t("alerts.disabled", model: t("activerecord.models.customer"))

    else
      redirect_to customer_path(@customer), notice: t("alerts.disabled", model: t("activerecord.models.customer"))
    end
  end

  # Send unlock email to the user
  def send_confirmation_email
    # Generate random token
    generate_token

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    @customer.user.update_attribute(:confirmation_sent, true)
    @customer.user.update_attribute(:confirmation_token, @token)

    # Send email
    AuthenticationMailer.confirmation_instructions(@customer.user, @token, I18n.locale, ip, location).deliver
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(confirmation_token: @token).exists?
    end
  end

  private

  # Set Customer
  def set_customer
    @customer = Customer.find(current_customer.id)

  rescue
    redirect_to sign_in_path, alert: t("alerts.not_found", model: t("activerecord.models.user"))
  end

  # Customer params
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :company, :email, :phone, :zipcode, :address, :image, user_attributes: [:email, :password, :password_confirmation, :two_factor_auth])
  end
end
