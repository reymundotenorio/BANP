class Admin::Authentication::PasswordsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  def new
    @email = params[:email].strip.downcase!
    hide_message = params[:hide_message]

    if hide_message
      @hide_message = true

    else
      @hide_message = false
    end

    if @email

    else
      @email = ""
    end
  end

  # /unlock-employee-account/:reset_password_token
  def show
    @token = params[:reset_password_token]
    @not_found = false;
    max_failed_attempts = 4

    # If token has been found
    if @employee = Employee.find_by(reset_password_token: @token)

      # If user is enabled
      if @employee.state

        # If user is confirmed
        if @employee.confirmed

          # If user has exceeded the max of failed attemps
          if @employee.failed_attempts  >= max_failed_attempts
            redirect_to admin_unlock_account_path(email: @employee.email), alert: t('views.authentication.account_locked', email: @employee.email)

            # If user has not exceeded the max of failed attemps
          else
            #show update password form
          end

          # If user is not confirmed
        else
          redirect_to admin_confirm_account_path(email: @employee.email), alert: t("views.authentication.account_not_confirmed_resend", email: @employee.email)
        end

        # If user is disabled
      else
        flash[:alert] = t('views.authentication.account_disabled')
        @not_found = true
      end

      # If token has not been found
    else
      flash[:alert] = t('views.authentication.token_not_found', token: @token)
      @not_found = true
    end

    render :show
  end

  # Send unlock email to the user
  def send_unlock_email
    max_failed_attempts = 4

    # If email has been found
    if @employee = Employee.find_by(email: params[:resend_reset_password][:email])

      # If user is enabled
      if @employee.state

        # If user is disabled
      else
        flash[:alert] = t('views.authentication.account_disabled')
        render :new
      end

      # If email has not been found
    else
      flash[:alert] = t('views.authentication.email_not_found', email: email)
      render :new
    end

    # Generate random token
    generate_token

    @employee.update_attribute(:reset_password_sent, true)
    @employee.update_attribute(:reset_password_token, @token)

    # Render Sync with external controller
    sync_update @employee

    # Send email
    AuthenticationMailer.reset_password_instructions(@employee, @token, I18n.locale).deliver

    render :new
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(reset_password_token: @token).exists?
    end
  end
end
