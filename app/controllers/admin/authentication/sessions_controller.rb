class Admin::Authentication::SessionsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /sign-in
  def new
    # Redirect if user is not authenticated with two factor yet
    if session[:employee_id] && session[:session_confirmed] == false
      redirect_to admin_two_factor_path
      return

      # Redirect if user is already authenticated
    elsif session[:employee_id] && session[:session_confirmed] == true
      redirect_to admin_root_path
      return
    end

    @email = params[:email]
    @email = @email.blank? ? "" : @email.strip.downcase
  end

  # Sign in
  def create
    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_sign_in_path, alert: t("views.form.recaptcha_error")
      return
    end

    # If user exists
    if set_user
      # Verify if user is not employee
      if !user_is_employee?
        return
      end

      # If user is disabled
      if !employee_enabled?
        return
      end

      # If user is not confirmed
      if !user_confirmed?
        return
      end

      # If user has exceeded the max of failed attemps
      if user_locked?(false)

        # If unlock email has not been sent
        send_unlock_email unless @user.unlock_sent

        redirect_to admin_auth_notifications_path(source: "unlock"), alert: t("views.authentication.account_locked", email: @user.email)
        return

        # If user is not locked
      else
        # If user exist and password matches
        if @user && @user.authenticate(params[:sign_in][:password])
          reset_attemps

          session_info
          session[:employee_id] = @user.id

          # If user has two factor authentication enabled
          if @user.two_factor_auth
            session[:session_confirmed] = false

            generate_otp
            @user.update(two_factor_auth_otp: @OTP)

            send_otp
            redirect_to admin_two_factor_path
            return
          end

          session[:session_confirmed] = true

          redirect_to admin_employees_path, notice: t("views.authentication.signed_in_correctly", first_name: @employee.first_name, last_name: @employee.last_name)

          # If user exist but the password doesn't match
        else
          remaining_attempts = $max_failed_attempts - increment_attempts
          remaining_attempts += 1

          redirect_to admin_sign_in_path, alert: "#{t('views.authentication.incorrect_pwd')}, #{remaining_attempts} #{remaining_attempts == 1 ? t('views.authentication.remaining_attempt') : t('views.authentication.remaining_attempts')}"
        end
      end
    end
    # End if user exists
  end

  # Verify if user has sign in correctly
  def two_factor
    # Redirect if user is already authenticated
    if session[:employee_id] && session[:session_confirmed] == true
      redirect_to admin_root_path
      return
    end

    # If user exists
    if set_user_with_two_factor
      # Verify if user is not employee
      if !user_is_employee?
        return
      end

      # If employee is disabled
      if !employee_enabled?
        return
      end

      # If user is not confirmed
      if !user_confirmed?
        return
      end

      # If user has exceeded the max of failed attemps
      if @user.failed_attempts > $max_failed_attempts
        session[:employee_id] = nil
        session[:session_confirmed] = nil

        # If unlock email has not been sent
        send_unlock_email unless @user.unlock_sent

        redirect_to admin_auth_notifications_path(source: "unlock"), alert: t("views.authentication.account_locked", email: @user.email)
        return
      end

      if session[:session_confirmed] == true
        redirect_to admin_employees_path
        return
      end
    end
    # End if user exists
  end

  # Validating the two factor otp
  def two_factor_auth
    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_two_factor_path, alert: t("views.form.recaptcha_error")
      return
    end

    # If user exists
    if set_user_with_two_factor
      # Verify if user is not employee
      if !user_is_employee?
        return
      end

      otp = params[:two_factor][:otp]
      otp = otp.strip

      if @user.two_factor_auth_otp == otp
        session[:session_confirmed] = true
        redirect_to admin_employees_path, notice: t("views.authentication.signed_in_correctly", first_name: @employee.first_name, last_name: @employee.last_name)

      else
        remaining_attempts = $max_failed_attempts - increment_attempts
        remaining_attempts += 1

        redirect_to admin_two_factor_path, alert: "#{t('views.authentication.incorrect_otp')}, #{remaining_attempts} #{remaining_attempts == 1 ? t('views.authentication.remaining_attempt') : t('views.authentication.remaining_attempts')}"
      end
    end
    # End if user exists
  end

  # Set user with two factor authentication
  def set_user_with_two_factor
    @user = User.find(session[:employee_id]) if session[:employee_id] && session[:session_confirmed] == false

    if @user
      return true

    else
      redirect_to admin_two_factor_path, alert: t("views.authentication.sign_in_required")
      return false
    end
  end

  def resend_otp
    set_user_with_two_factor

    # Verify if user is not employee
    if !user_is_employee?
      return
    end

    generate_otp
    @user.update(two_factor_auth_otp: @OTP)

    send_otp
    redirect_to admin_two_factor_path, notice: t("views.authentication.otp_resended")
    return
  end

  # Generate random and unique OTP
  def generate_otp
    loop do
      @OTP = 6.times.map{rand(0...10)}.join # Excluding 10
      @OTP = @OTP.to_s.strip
      break @OTP unless User.where(two_factor_auth_otp: @OTP).exists?
    end
  end

  # Send OTP by SMS
  def send_otp
    send_sms(@employee.phone, "BANP - #{t('views.authentication.otp_sms', otp: @OTP)}")
    return
  end

  # Set user
  def set_user
    email = params[:sign_in][:email]
    email = email.strip.downcase

    if @user = User.find_by(email: email)
      return true

    else
      flash.now[:alert] = t("views.authentication.incorrect_user_pwd")
      render :new
      return false
    end
  end

  # Send unlock email to the user
  def send_unlock_email
    # Generate random token
    generate_token

    @user.update(unlock_sent: true)
    @user.update(unlock_token: @token)

    # Render Sync with external controller
    sync_update @user

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country


    # Send SMS
    send_sms(@employee.phone, "BANP - #{t('views.mailer.greetings')} #{@employee.first_name}. #{t('views.mailer.unlock_account_link')}: #{admin_unlock_employee_account_url(unlock_token: @token)}")

    # Send email
    AuthenticationMailer.unlock_instructions(@user, @token, I18n.locale, ip, location).deliver
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(unlock_token: @token).exists?
    end
  end

  # Save session information
  def session_info
    sign_in_count = @user.sign_in_count
    sign_in_count += 1

    @user.update(sign_in_count: sign_in_count)

    if @user.last_sign_in_at.blank?
      @user.update(last_sign_in_at: Time.zone.now)

    else
      @user.update(last_sign_in_at: @user.current_sign_in_at)
    end

    if @user.last_sign_in_ip.blank?
      @user.update(last_sign_in_ip: request.remote_ip)

    else
      @user.update(last_sign_in_ip: @user.current_sign_in_ip)
    end

    @user.update(current_sign_in_at: Time.zone.now)
    @user.update(current_sign_in_ip: request.remote_ip)

    # Render Sync with external controller
    sync_update @user
  end

  # Reset failed attemps count
  def reset_attemps
    @user.update(failed_attempts: 0)
    @user.update(unlock_sent: false)

    # Render Sync with external controller
    sync_update @user
  end

  # Increment failed attemps count
  def increment_attempts
    failed_attempts = @user.failed_attempts
    failed_attempts += 1

    @user.update(failed_attempts: failed_attempts)

    # Render Sync with external controller
    sync_update @user

    failed_attempts
  end

  # /sign-out
  def destroy
    @email = params[:email]

    session[:employee_id] = nil
    session[:session_confirmed] = nil

    if @email
      redirect_to admin_sign_in_path(email: @email), notice: t("views.authentication.locked_correctly")
      return

    else
      redirect_to admin_sign_in_path, notice: t("views.authentication.signed_out_correctly")
      return
    end
  end
end
