class Admin::Authentication::UnlocksController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /unlock-employee-account
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

  # /unlock-employee-account/:unlock_token
  def show
    @token = params[:unlock_token]
    @not_found = false;

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
        @employee.update(failed_attempts: 0)

        # Render Sync with external controller
        sync_update @employee

        redirect_to admin_auth_notifications_path, notice: t('views.authentication.successfully_unlocked', email: @employee.email)
        return

      else
        redirect_to admin_auth_notifications_path, notice:  t('views.authentication.account_unlocked', email: @employee.email)
        return
      end
    end
    # End If token has been found

  end

  # Set Employee
  def set_employee
    if  @employee = Employee.find_by(unlock_token: @token)
      return true

    else
      redirect_to redirect_to admin_auth_notifications_path, alert: t('views.authentication.token_not_found',  token: @token)
      return false
    end
  end

  # Send unlock email to the user
  def send_unlock_email

    # If email has been found
    if @employee = Employee.find_by(email: params[:resend_unlock][:email].strip!.downcase!)

      # If user is disabled
      if !employee_enabled?
        return
      end

      # If user is not confirmed
      if !employee_confirmed?
        return
      end

      # If email has not been found
    else
      redirect_to admin_auth_notifications_path, alert: t('views.authentication.email_not_found', email: params[:resend_reset_password][:email].strip!.downcase!)
      return
    end

    # Generate random token
    generate_token

    @employee.update_attribute(:unlock_sent, true)
    @employee.update_attribute(:unlock_token, @token)

    # Render Sync with external controller
    sync_update @employee

    # Send email
    AuthenticationMailer.unlock_instructions(@employee, @token, I18n.locale).deliver

    flash[:notice] = t("views.authentication.email_sent", @employee.email)
    render :new
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(unlock_token: @token).exists?
    end
  end
end
