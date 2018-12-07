class Authentication::UnlocksController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /unlock-costumer-account
  def new
    @email = params[:email]
    @email = @email.blank? ? "" : @email.strip.downcase
  end

  # /unlock-costumer-account/:unlock_token
  def show
    @token = params[:unlock_token]

    # If token has been found
    if set_user
      # Verify if user is not costumer
      if !user_is_costumer?
        return
      end

      # If costumer is disabled
      if !costumer_enabled?
        return
      end

      # If user is not confirmed
      if !user_confirmed?
        return
      end

      # If user has exceeded the max of failed attemps
      if user_locked?(false)
        @user.update(failed_attempts: 0)
        @user.update(unlock_sent: false)

        # Render Sync with external controller
        sync_update @user

        redirect_to auth_notifications_path, notice: t("views.authentication.successfully_unlocked", email: @user.email)
        return

      else
        redirect_to auth_notifications_path, notice:  t("views.authentication.account_unlocked", email: @user.email)
        return
      end
    end
    # End If token has been found
  end

  # Set user
  def set_user
    if @user = User.find_by(unlock_token: @token)
      return true

    else
      redirect_to auth_notifications_path(source: "unlock"), alert: t("views.authentication.token_not_found", token: @token)
      return false
    end
  end

  # Send unlock email to the user
  def send_unlock_email
    email = params[:resend_unlock][:email]
    email = email.strip.downcase

    # Verify recaptcha
    if !verify_recaptcha
      redirect_to unlock_account_path(email: email), alert: t("views.form.recaptcha_error")
      return
    end

    # If email has been found
    if @user = User.find_by(email: email)
      # Verify if user is not costumer
      if !user_is_costumer?
        return
      end

      # If costumer is disabled
      if !costumer_enabled?
        return
      end

      # If user is not confirmed
      if !user_confirmed?
        return
      end

      # If email has not been found
    else
      redirect_to auth_notifications_path(source: "unlock"), alert: t("views.authentication.email_not_found", email: email)
      return
    end

    # Generate random token
    generate_token

    @user.update(unlock_sent: true)
    @user.update(unlock_token: @token)

    # Render Sync with external controller
    sync_update @user

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.unlock_instructions(@user, @token, I18n.locale, ip, location).deliver

    flash.now[:notice] = t("views.authentication.email_sent", email: @user.email)
    render :new
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(unlock_token: @token).exists?
    end
  end
end
