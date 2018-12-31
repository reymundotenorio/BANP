class Authentication::ConfirmationsController < ApplicationController
   # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /confirm-customer-account
  def new
    @email = params[:email]
    @email = @email.blank? ? "" : @email.strip.downcase
  end

  # /confirm-customer-account/:confirmation_token
  def show
    @token = params[:confirmation_token]

    # If token has been found
    if set_user
      # Verify if user is not customer
      if !user_is_customer?
        return
      end

      # If user is disabled
      if !customer_enabled?
        return
      end

      # If user has exceeded the max of failed attemps
      if user_locked?(true, false)
        return
      end

      # If user is not confirmed yet
      if !user_confirmed?(false, false)
        @user.update(confirmed: true)
        @user.update(confirmation_sent: false)

        # If user is a client
        # Render Sync with external controller
        sync_update @user

        redirect_to auth_notifications_path, notice: t("views.authentication.successfully_confirmed", email: @user.email)
        return

        # If user is already confirmed
      else
        redirect_to auth_notifications_path, notice:  t("views.authentication.account_confirmed", email: @user.email)
        return
      end
    end
    # End If token has been found
  end

  # Set user
  def set_user
    if @user = User.find_by(confirmation_token: @token)
      return true

    else
      redirect_to auth_notifications_path(source: "reset-password"), alert: t("views.authentication.token_not_found", token: @token)
      return false
    end
  end

  # Send unlock email to the user
  def send_confirmation_email
    email = params[:resend_confirmation][:email]
    email = email.strip.downcase

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to confirm_account_path(email: email), alert: t("views.form.recaptcha_error")
      return
    end

    # If email has been found
    if @user = User.find_by(email: email)
      # Verify if user is not customer
      if !user_is_customer?
        return
      end

      # If customer is disabled
      if !customer_enabled?
        return
      end

      # If user has exceeded the max of failed attemps
      if user_locked?(true, false)
        return
      end

      # If email has not been found
    else
      redirect_to auth_notifications_path(source: "confirmation"), alert: t("views.authentication.email_not_found", email: email)
      return
    end

    # Generate random token
    generate_token

    @user.update(confirmation_sent: true)
    @user.update(confirmation_token: @token)

    # Render Sync with external controller
    sync_update @user

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.confirmation_instructions(@user, @token, I18n.locale, ip, location).deliver

    flash.now[:notice] = t("views.authentication.email_sent", email: @user.email)
    render :new
  end

  # Generate token for password
  def generate_token_password
    loop do
      @token_password = SecureRandom.hex(15)
      break @token_password unless User.where(reset_password_token: @token_password).exists?
    end
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(confirmation_token: @token).exists?
    end
  end
end
