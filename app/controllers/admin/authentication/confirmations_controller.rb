class Admin::Authentication::ConfirmationsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /confirm-employee-account
  def new
    @email = params[:email]
    @email = @email.blank? ? "" : @email.strip.downcase
  end

  # /confirm-employee-account/:confirmation_token
  def show
    @token = params[:confirmation_token]

    # If token has been found
    if set_employee

      # If user is disabled
      if !employee_enabled?
        return
      end

      # If user has exceeded the max of failed attemps
      if employee_locked?
        return
      end

      # If user is not confirmed yet
      if !employee_confirmed?(false)
        @employee.update(confirmed: true)
        @employee.update(confirmation_sent: false)

        # Render Sync with external controller
        sync_update @employee

        redirect_to admin_auth_notifications_path, notice: t("views.authentication.successfully_confirmed", email: @employee.email)
        return

        # If user is already confirmed
      else
        redirect_to admin_auth_notifications_path, notice:  t("views.authentication.account_confirmed", email: @employee.email)
        return
      end
    end
    # End If token has been found
  end

  # Set Employee
  def set_employee
    if @employee = Employee.find_by(confirmation_token: @token)
      return true

    else
      redirect_to admin_auth_notifications_path(source: "reset-password"), alert: t("views.authentication.token_not_found", token: @token)
      return false
    end
  end

  # Send unlock email to the user
  def send_confirmation_email
    email = params[:resend_confirmation][:email]
    email = email.strip.downcase

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_confirm_account_path(email: email), alert: t("views.form.recaptcha_error")
      return
    end

    # If email has been found
    if @employee = Employee.find_by(email: email)
      # If user is disabled
      if !employee_enabled?
        return
      end

      # If user has exceeded the max of failed attemps
      if employee_locked?
        return
      end

      # If email has not been found
    else
      redirect_to admin_auth_notifications_path(source: "confirmation"), alert: t("views.authentication.email_not_found", email: email)
      return
    end

    # Generate random token
    generate_token

    @employee.update(confirmation_sent: true)
    @employee.update(confirmation_token: @token)

    # Render Sync with external controller
    sync_update @employee

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.confirmation_instructions(@employee, @token, I18n.locale, ip, location).deliver

    flash[:notice] = t("views.authentication.email_sent", email: @employee.email)
    render :new
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(confirmation_token: @token).exists?
    end
  end
end
