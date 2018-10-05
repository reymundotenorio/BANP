class Admin::Authentication::PasswordsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /resend-reset-password
  def new
    @email = params[:email]

    hide_message = params[:hide_message]

    if hide_message
      @hide_message = true

    else
      @hide_message = false
    end

    if @email
      @email.strip!.downcase!
    else
      @email = ""
    end
  end

  # /resend-reset-password/:reset_password_token
  def show
    @token = params[:reset_password_token]

    # If token has been found
    if set_employee
      # If user is disabled
      if !employee_enabled?
        return
      end

      # If user is not confirmed
      if !employee_confirmed?
        return
      end

      # If user has exceeded the max of failed attemps
      if employee_locked?
        return
      end
    end
    # End If token has been found
  end

  # Set Employee
  def set_employee
    if  @employee = Employee.find_by(reset_password_token: @token)
      return true

    else
      redirect_to admin_auth_notifications_path, alert: t('views.authentication.token_not_found',  token: @token)
      return false
    end
  end

  # Update password
  def update_password
    set_employee

    if @employee.update(employee_params)
      redirect_to admin_auth_notifications_path, notice: "Contraseña actualizada"
    else
      render :show
    end
  end

  # Send reset email to the user
  def send_reset_password_email
    # RESET FLASH

    # If email has been found
    if @employee = Employee.find_by(email: params[:resend_reset_password][:email].strip!.downcase!)
      # If user is disabled
      if !employee_enabled?
        return
      end

      # If user is not confirmed
      if !employee_confirmed?
        return
      end

      # If user has exceeded the max of failed attemps
      if employee_locked?
        return
      end

      # If email has not been found
    else
      redirect_to admin_auth_notifications_path, alert: t('views.authentication.email_not_found', email: params[:resend_reset_password][:email].strip!.downcase!)
      return
    end

    # Generate random token
    generate_token

    @employee.update_attribute(:reset_password_sent, true)
    @employee.update_attribute(:reset_password_token, @token)

    # Render Sync with external controller
    sync_update @employee

    # Send email
    AuthenticationMailer.reset_password_instructions(@employee, @token, I18n.locale).deliver

    redirect_to admin_auth_notifications_path, notice: t("views.authentication.email_sent", email: @employee.email)
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(reset_password_token: @token).exists?
    end
  end

  private

  def employee_params
    params.require(:employee).permit(:password, :password_confirmation)
  end
end
