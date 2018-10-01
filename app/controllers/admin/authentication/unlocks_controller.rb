class Admin::Authentication::UnlocksController < ApplicationController
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

  # /unlock-employee-account/:unlock_token
  def show
    @token = params[:unlock_token]
    @not_found = false;
    max_failed_attempts = 4

    # If token has been found
    if @employee = Employee.find_by(unlock_token: @token)

      # If user is enabled
      if @employee.state

        # If user is confirmed
        if @employee.confirmed

          # If user has exceeded the max of failed attemps
          if @employee.failed_attempts  >= max_failed_attempts
            @employee.update_attribute(:failed_attempts, 0)

            # Render Sync with external controller
            sync_update @employee

            flash[:notice] = t('views.authentication.successfully_unlocked', email: @employee.email)

            # If user has not exceeded the max of failed attemps
          else
            flash[:notice] = t('views.authentication.account_unlocked', email: @employee.email)
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

    # If email has been found
    if @employee = Employee.find_by(email: params[:resend_unlock][:email])

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

    @employee.update_attribute(:unlock_sent, true)
    @employee.update_attribute(:unlock_token, @token)

    # Render Sync with external controller
    sync_update @employee

    # Send email
    AuthenticationMailer.unlock_instructions(@employee, @token, I18n.locale).deliver

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
