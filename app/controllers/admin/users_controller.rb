class Admin::UsersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employee with Friendly_ID
  before_action :set_employee, only: [:new_employee_user, :create_employee_user, :employee_update_password, :employee_change_password]
  # End Find employee with Friendly_ID

  # Find customer with Friendly_ID
  before_action :set_customer, only: [:new_customer_user, :create_customer_user, :customer_update_password, :customer_change_password]
  # End Find customer with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create_employee_user, :create_customer_user, :employee_change_password, :customer_change_password, :send_confirmation_email]
  # End Sync model DSL

  # admin/employee/:id/create-user
  def new_employee_user
    if @employee.user.present?
      redirect_to admin_employee_path(@employee), alert: t("views.authentication.employee_user_exists")
      return
    end

    @user = User.new
    @form_url = admin_create_employee_user_path
    @required = true
  end

  # admin/customer/:id/create-user
  def new_customer_user
    if @customer.user.present?
      redirect_to admin_customer_path(@customer), alert: t("views.authentication.employee_user_exists")
      return
    end

    @user = User.new
    @form_url = admin_create_customer_user_path
    @required = true
  end

  # admin/employee/:id/update-password
  def employee_update_password
    @user = @employee.user
    @form_url = admin_change_password_employee_path
    @required = false
  end

  # admin/customer/:id/update-password
  def customer_update_password
    @user = @customer.user
    @form_url = admin_change_password_customer_path
    @required = false
  end

  # Create user to the employee
  def create_employee_user
    create_params = user_params

    if create_params[:two_factor_auth] == "true"
      create_params[:two_factor_auth] = true

    else
      create_params[:two_factor_auth] = false
    end

    @user = @employee.build_user(create_params)

    if @user.save
      send_confirmation_email
      redirect_to [:admin, @employee], notice: "#{t('alerts.created', model: t('activerecord.models.employee'))}. #{t('views.authentication.account_not_confirmed', email: @user.email)}"

      # If record was not saved
    else
      @form_url = admin_create_employee_user_path
      render :new_employee_user
    end
  end

  # Create user to the customer
  def create_customer_user
    create_params = user_params

    if create_params[:two_factor_auth] == "true"
      create_params[:two_factor_auth] = true

    else
      create_params[:two_factor_auth] = false
    end

    @user = @customer.build_user(create_params)

    if @user.save
      send_confirmation_email
      redirect_to [:admin, @customer], notice: "#{t('alerts.created', model: t('activerecord.models.customer'))}. #{t('views.authentication.account_not_confirmed', email: @user.email)}"

      # If record was not saved
    else
      @form_url = admin_create_customer_user_path
      render :new_customer_user
    end
  end

  # Change employee password
  def employee_change_password
    @user = @employee.user
    update_params = user_params

    if update_params[:two_factor_auth] == "true"
      update_params[:two_factor_auth] = true
    else
      update_params[:two_factor_auth] = false
    end

    if @user.update(update_params)
      redirect_to [:admin, @employee], notice: t("views.mailer.password_and_2FA_updated")

    else
      @form_url = admin_change_password_employee_path
      render :employee_update_password
    end
  end

  # Change customer password
  def customer_change_password
    @user = @customer.user
    update_params = user_params

    if update_params[:two_factor_auth] == "true"
      update_params[:two_factor_auth] = true
    else
      update_params[:two_factor_auth] = false
    end

    if @user.update(update_params)
      redirect_to [:admin, @customer], notice: t("views.mailer.password_and_2FA_updated")

    else
      @form_url = admin_change_password_customer_path
      render :customer_update_password
    end
  end

  # Send unlock email to the user
  def send_confirmation_email
    # Generate random token
    generate_token

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    if @employee
      @employee.user.update_attribute(:confirmation_sent, true)
      @employee.user.update_attribute(:confirmation_token, @token)

      # Send email
      AdminAuthenticationMailer.confirmation_instructions(@employee.user, @token, I18n.locale, ip, location).deliver
    end

    if @customer
      @customer.user.update_attribute(:confirmation_sent, true)
      @customer.user.update_attribute(:confirmation_token, @token)

      # Send email
      AuthenticationMailer.confirmation_instructions(@customer.user, @token, I18n.locale, ip, location).deliver
    end
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(confirmation_token: @token).exists?
    end
  end

  private

  # Set Employee
  def set_employee
    @employee = Employee.friendly.find(params[:id])

  rescue
    redirect_to admin_employees_path, alert: t("alerts.not_found", model: t("activerecord.models.employee"))
  end

  # Set Customer
  def set_customer
    @customer = Customer.friendly.find(params[:id])

  rescue
    redirect_to admin_customers_path, alert: t("alerts.not_found", model: t("activerecord.models.customer"))
  end

  # User params
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :two_factor_auth)
  end
end
