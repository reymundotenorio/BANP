class Admin::UsersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employees with Friendly_ID
  before_action :set_employee, only: [:new_employee_user, :create_employee_user, :employee_update_password, :employee_change_password]
  # End Find employees with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create_employee_user, :employee_change_password, :send_confirmation_email]
  # End Sync model DSL

  # /employee/:id/create-user
  def new_employee_user
    @user = User.new
    @form_url = admin_create_employee_user_path
  end

  # /employee/:id/update-password
  def employee_update_password
    @user = @employee.user
    @form_url = admin_change_password_employee_path
  end

  def create_employee_user
    @user = @employee.build_user(user_params)

    if @user.save
      redirect_to [:admin, @employee], notice: "Usuario creado"

      # If record was not saved
    else
      render :new_employee_user
    end
  end

  # Change password
  def employee_change_password
    @user = @employee.user

    if @user.update(user_params)
      redirect_to [:admin, @employee], notice: t("views.mailer.password_updated")

    else
      render :employee_update_password
    end
  end

  # Send unlock email to the user
  def send_confirmation_email
    # Generate random token
    generate_token

    @employee.user.update_attribute(:confirmation_sent, true)
    @employee.user.update_attribute(:confirmation_token, @token)

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.confirmation_instructions(@employee.user, @token, I18n.locale, ip, location).deliver
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
    redirect_to admin_employees_path, alert: "No se pudo encontrar"
  end

  # User params
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
