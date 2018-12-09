class Admin::UsersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employee with Friendly_ID
  before_action :set_employee, only: [:new_employee_user, :create_employee_user, :employee_update_password, :employee_change_password]
  # End Find employee with Friendly_ID

  # Find costumer with Friendly_ID
  before_action :set_costumer, only: [:new_costumer_user, :create_costumer_user, :costumer_update_password, :costumer_change_password]
  # End Find costumer with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create_employee_user, :create_costumer_user, :employee_change_password, :costumer_change_password, :send_confirmation_email]
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

  # admin/costumer/:id/create-user
  def new_costumer_user
    if @costumer.user.present?
      redirect_to admin_costumer_path(@costumer), alert: t("views.authentication.employee_user_exists")
      return
    end

    @user = User.new
    @form_url = admin_create_costumer_user_path
    @required = true
  end

  # admin/employee/:id/update-password
  def employee_update_password
    @user = @employee.user
    @form_url = admin_change_password_employee_path
    @required = false
  end

  # admin/costumer/:id/update-password
  def costumer_update_password
    @user = @costumer.user
    @form_url = admin_change_password_costumer_path
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

  # Create user to the costumer
  def create_costumer_user
    create_params = user_params

    if create_params[:two_factor_auth] == "true"
      create_params[:two_factor_auth] = true

    else
      create_params[:two_factor_auth] = false
    end

    @user = @costumer.build_user(create_params)

    if @user.save
      send_confirmation_email
      redirect_to [:admin, @costumer], notice: "#{t('alerts.created', model: t('activerecord.models.costumer'))}. #{t('views.authentication.account_not_confirmed', email: @user.email)}"

      # If record was not saved
    else
      @form_url = admin_create_costumer_user_path
      render :new_costumer_user
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

  # Change costumer password
  def costumer_change_password
    @user = @costumer.user
    update_params = user_params

    if update_params[:two_factor_auth] == "true"
      update_params[:two_factor_auth] = true
    else
      update_params[:two_factor_auth] = false
    end

    if @user.update(update_params)
      redirect_to [:admin, @costumer], notice: t("views.mailer.password_and_2FA_updated")

    else
      @form_url = admin_change_password_costumer_path
      render :costumer_update_password
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

    if @costumer
      @costumer.user.update_attribute(:confirmation_sent, true)
      @costumer.user.update_attribute(:confirmation_token, @token)
      
      # Send email
      AdminAuthenticationMailer.confirmation_instructions(@costumer.user, @token, I18n.locale, ip, location).deliver
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

  # Set Costumer
  def set_costumer
    @costumer = Costumer.friendly.find(params[:id])

  rescue
    redirect_to admin_costumers_path, alert: t("alerts.not_found", model: t("activerecord.models.costumer"))
  end

  # User params
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :two_factor_auth)
  end
end
