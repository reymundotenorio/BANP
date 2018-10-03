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
      @email.strip.downcase!
    else
      @email = ""
    end
  end

  # /resend-reset-password/:reset_password_token
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
            return

            # If user has not exceeded the max of failed attemps
          else
            #show update password form
          end

          # If user is not confirmed
        else
          redirect_to admin_confirm_account_path(email: @employee.email), alert: t("views.authentication.account_not_confirmed_resend", email: @employee.email)
          return
        end

        # If user is disabled
      else
        flash[:alert] = t('views.authentication.account_disabled')
        @not_found = true
      end

      # If token has not been found
    else
      redirect_to admin_reset_password_path, alert: t('views.authentication.token_not_found', token: @token)
      return
    end

    render :show
  end

  def update_password
    if  @employee.update(employee_params)

      redirect_to admin_sign_in_path, notice: "YES"
    else
      redirect_to admin_sign_in_path, alert: "NO"
    end
  end

  # Send reset email to the user
  def send_reset_password_email
    # max_failed_attempts = 4
    # RESET FLASH

    # If email has been found
    if @employee = Employee.find_by(email: params[:resend_reset_password][:email])

      # If user is enabled
      if @employee.state

        # If user is disabled
      else
        flash[:alert] = t('views.authentication.account_disabled')
        render :new
        return
      end

      # If email has not been found
    else
      flash[:alert] = t('views.authentication.email_not_found', email: params[:resend_reset_password][:email])
      render :new
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

    flash[:notice] = t("views.authentication.email_sent", email: @employee.email)
    render :new
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
