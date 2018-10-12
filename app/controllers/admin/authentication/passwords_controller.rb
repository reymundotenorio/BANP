class Admin::Authentication::PasswordsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /resend-reset-password
  def new
    @email = params[:email]
    @email = @email.blank? ? "" : @email.strip.downcase
  end

  # /resend-reset-password/:reset_password_token
  def show
    @token = params[:reset_password_token]
    @employee_password = params[:employee_password]

    @employee_password = @employee_password.blank? ? false : true

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

      if email_expired?
        redirect_to admin_reset_password_path(email: @employee.email), alert: t("views.authentication.email_expired")
        return
      end
    end
    # End If token has been found
  end

  # If email has expired
  def email_expired?

    # If is the first-time reset password for employee
    if @employee.reset_password_sent && @employee.reset_password_sent_at != nil
      # If the time has exceeded the 2 hours
      if @employee.reset_password_sent_at + 2.hours < Time.zone.now
        return true

        # If the time has not exceeded the 2 hours
      else
        return false
      end

      # If is not the first-time reset password for employee
    else
      return false
    end
  end

  # Set Employee
  def set_employee
    if @employee = Employee.find_by(reset_password_token: @token)
      return true

    else
      redirect_to admin_auth_notifications_path(source: "reset-password"), alert: t("views.authentication.token_not_found", token: @token)
      return false
    end
  end

  # Update password
  def update_password
    @token = params[:token]
    set_employee

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_reset_employee_password_path(reset_password_token: @token), alert: t("views.form.recaptcha_error")
      return
    end

    if @employee.update(employee_params)
      @employee.update(reset_password_sent: false)

      # Render Sync with external controller
      sync_update @employee

      send_password_update_email

      redirect_to admin_auth_notifications_path, notice: "Contraseña actualizada #{@employee.email}"
    else
      render :show
    end
  end

  # Send reset email to the user
  def send_reset_password_email
    email = params[:resend_reset_password][:email]
    email = email.strip.downcase

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_reset_password_path(email: email), alert: t("views.form.recaptcha_error")
      return
    end

    # If email has been found
    if @employee = Employee.find_by(email: email)
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
      redirect_to admin_auth_notifications_path(source: "reset-password"), alert: t("views.authentication.email_not_found", email: email)
      return
    end

    # Generate random token
    generate_token

    @employee.update(reset_password_sent: true)
    @employee.update(reset_password_token: @token)
    @employee.update(reset_password_sent_at: Time.zone.now)

    # Render Sync with external controller
    sync_update @employee

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.reset_password_instructions(@employee, @token, I18n.locale, ip, location).deliver

    redirect_to admin_auth_notifications_path, notice: t("views.authentication.email_sent", email: @employee.email)
  end

  # Send notification email to the user
  def send_password_update_email

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send SMS
    send_sms(@employee.phone, "BANP - #{t('views.mailer.greetings')} #{@employee.first_name}, #{t('views.mailer.password_updated_link')}: #{admin_reset_password_url(email: @employee.email)}")

    # Send email
    AuthenticationMailer.password_update(@employee, I18n.locale, ip, location).deliver
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
