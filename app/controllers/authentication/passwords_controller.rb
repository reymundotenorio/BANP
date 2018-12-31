class Authentication::PasswordsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # Authentication
  before_action :require_customer, only: [:edit_password]
  # End Authentication

  # /resend-reset-password
  def new
    @email = params[:email]
    @email = @email.blank? ? "" : @email.strip.downcase
  end

  # /resend-reset-password/:reset_password_token
  def show
    @token = params[:reset_password_token]
    @customer_password = params[:customer_password]

    @customer_password = @customer_password.blank? ? false : true

    # If token has been found
    if set_user
      # Verify if user is not customer
      if !user_is_customer?
        return
      end

      # If customer is disabled
      if !customer_enabled?
        return
      end

      # If user is not confirmed
      if !user_confirmed?(true, false)
        return
      end

      # If user has exceeded the max of failed attemps
      if user_locked?(true, false)
        return
      end

      if email_expired?
        redirect_to reset_password_path(email: @user.email), alert: t("views.authentication.email_expired")
        return
      end
    end
    # End If token has been found
  end

  # Update password
  def update_password
    @token = params[:token]

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to reset_customer_password_path(reset_password_token: @token), alert: t("views.form.recaptcha_error")
      return
    end

    # Set user by token found
    set_user

    # Verify if user is not customer
    if !user_is_customer?
      return
    end

    if @user.update(user_params)
      @user.update(reset_password_sent: false)

      # Render Sync with external controller
      sync_update @user

      send_update_password_email

      redirect_to auth_notifications_path, notice: t("views.mailer.password_updated")

    else
      render :show
    end
  end

  # If email has expired
  def email_expired?
    # If is the first-time reset password for user
    if @user.reset_password_sent && @user.reset_password_sent_at != nil
      # If the time has exceeded the 2 hours
      if @user.reset_password_sent_at + 2.hours < Time.zone.now
        return true

        # If the time has not exceeded the 2 hours
      else
        return false
      end

      # If is not the first-time reset password for user
    else
      return false
    end
  end

  # Send reset email to the user
  def send_reset_password_email
    email = params[:resend_reset_password][:email]
    email = email.strip.downcase

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to reset_password_path(email: email), alert: t("views.form.recaptcha_error")
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

      # If user is not confirmed
      if !user_confirmed?(true, false)
        return
      end

      # If user has exceeded the max of failed attemps
      if user_locked?(true, false)
        return
      end

      # If email has not been found
    else
      redirect_to auth_notifications_path(source: "reset-password"), alert: t("views.authentication.email_not_found", email: email)
      return
    end

    # Generate random token
    generate_token

    @user.update(reset_password_sent: true)
    @user.update(reset_password_token: @token)
    @user.update(reset_password_sent_at: Time.zone.now)

    # Render Sync with external controller
    sync_update @user

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.reset_password_instructions(@user, @token, I18n.locale, ip, location).deliver

    redirect_to auth_notifications_path, notice: t("views.authentication.email_sent", email: @user.email)
  end

  # Send notification email to the user
  def send_update_password_email
    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send SMS
    send_sms(@customer.phone, "BANP - #{t('views.mailer.greetings')} #{@customer.first_name} #{@customer.last_name}, #{t('views.mailer.password_updated_link')}: #{reset_password_url(email: @user.email)}")

    # Send email
    AuthenticationMailer.update_password(@user, I18n.locale, ip, location).deliver
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(reset_password_token: @token).exists?
    end
  end

  private

  # Set user
  def set_user
    if @user = User.find_by(reset_password_token: @token)
      return true

    else
      redirect_to auth_notifications_path(source: "reset-password"), alert: t("views.authentication.token_not_found", token: @token)
      return false
    end
  end

  # Set user by id
  def set_user_by_id
    if @user = User.friendly.find(params[:id])
      return true

    else
      redirect_to auth_notifications_path(source: "reset-password"), alert: t("views.authentication.token_not_found", token: @token)
      return false
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
