class Admin::Authentication::SessionsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /sign-in
  def new
    # Redirect if employee is not authenticated with two factor yet
    if session[:employee_id] && session[:session_confirmed] == false
      redirect_to admin_two_factor_path
      return

      # Redirect if employee is already authenticated
    elsif session[:employee_id] && session[:session_confirmed] == true
      redirect_to admin_root_path
      return
    end
  end

  # Sign in
  def create
    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_sign_in_path, alert: t("views.form.recaptcha_error")
      return
    end

    # If employee exists
    if set_employee
      # If employee is disabled
      if !employee_enabled?
        return
      end

      # If employee is not confirmed
      if !employee_confirmed?
        return
      end

      # If employee has exceeded the max of failed attemps
      if employee_locked?(false)

        # If unlock email has not been sent
        send_unlock_email unless @employee.unlock_sent

        redirect_to admin_auth_notifications_path(resource: "unlock"), alert: t("views.authentication.account_locked", email: @employee.email)
        return

        # If employee is not locked
      else
        # If employee exist and password matches
        if @employee && @employee.authenticate(params[:sign_in][:password])
          reset_attemps

          session_info
          session[:employee_id] = @employee.id

          # If employee has two factor authentication enabled
          if @employee.two_factor_auth
            session[:session_confirmed] = false

            generate_otp
            @employee.update(two_factor_auth_otp: @OTP)

            send_otp
            redirect_to admin_two_factor_path
            return
          end

          session[:session_confirmed] = true

          redirect_to admin_employees_path, notice: t("views.authentication.signed_in_correctly", first_name: @employee.first_name, last_name: @employee.last_name)

          # If employee exist but the password doesn't match
        else
          remaining_attempts = $max_failed_attempts - increment_attempts
          remaining_attempts += 1

          redirect_to admin_sign_in_path, alert: "#{t('views.authentication.incorrect_pwd')}, #{remaining_attempts} #{remaining_attempts == 1 ? t('views.authentication.remaining_attempt') : t('views.authentication.remaining_attempts')}"
        end
      end
    end
    # End iff employee exists
  end

  # Verify if employee has sign in correctly
  def two_factor
    # Redirect if employee is already authenticated
    if session[:employee_id] && session[:session_confirmed] == true
      redirect_to admin_root_path
      return
    end

    # If employee exists
    if set_employee_with_two_factor

      # If employee is disabled
      if !employee_enabled?
        return
      end

      # If employee is not confirmed
      if !employee_confirmed?
        return
      end

      # If employee has exceeded the max of failed attemps
      if @employee.failed_attempts > $max_failed_attempts
        session[:employee_id] = nil
        session[:session_confirmed] = nil

        # If unlock email has not been sent
        send_unlock_email unless @employee.unlock_sent

        redirect_to admin_auth_notifications_path(resource: "unlock"), alert: t("views.authentication.account_locked", email: @employee.email)
        return
      end

      if session[:session_confirmed] == true
        redirect_to admin_employees_path
        return
      end
    end
    # End if employee exists
  end

  # Validating the two factor otp
  def two_factor_auth
    # Verify recaptcha
    if !verify_recaptcha
      redirect_to admin_two_factor_path, alert: t("views.form.recaptcha_error")
      return
    end

    # If employee exists
    if set_employee_with_two_factor

      otp = params[:two_factor][:otp]
      otp = otp.strip

      if @employee.two_factor_auth_otp == otp
        session[:session_confirmed] = true
        redirect_to admin_employees_path, notice: t("views.authentication.signed_in_correctly", first_name: @employee.first_name, last_name: @employee.last_name)

      else
        remaining_attempts = $max_failed_attempts - increment_attempts
        remaining_attempts += 1

        redirect_to admin_two_factor_path, alert: "#{t('views.authentication.incorrect_otp')}, #{remaining_attempts} #{remaining_attempts == 1 ? t('views.authentication.remaining_attempt') : t('views.authentication.remaining_attempts')}"
      end
    end
    # End if employee exists
  end

  # Set Employee with two factor authentication
  def set_employee_with_two_factor
    @employee = Employee.find(session[:employee_id]) if session[:employee_id] && session[:session_confirmed] == false

    if @employee
      return true

    else
      redirect_to admin_two_factor_path, alert: t("views.authentication.sign_in_required")
      return false
    end
  end

  def resend_otp
    set_employee_with_two_factor

    generate_otp
    @employee.update(two_factor_auth_otp: @OTP)

    send_otp
    redirect_to admin_two_factor_path, notice: t("views.authentication.otp_resended")
    return
  end

  # Generate random and unique OTP
  def generate_otp
    loop do
      @OTP = 6.times.map{rand(0...10)}.join # Excluding 10
      @OTP = @OTP.to_s.strip
      break @OTP unless Employee.where(two_factor_auth_otp: @OTP).exists?
    end
  end

  # Send OTP by SMS
  def send_otp
    send_sms(@employee.phone, "BANP - #{t('views.authentication.otp_sms', otp: @OTP)}")
    return
  end

  # Set Employee
  def set_employee
    email = params[:sign_in][:email]
    email = email.strip.downcase

    if @employee = Employee.find_by(email: email)
      return true

    else
      flash.now[:alert] = t("views.authentication.incorrect_user_pwd")
      render :new
      return false
    end
  end

  # Send unlock email to the employee
  def send_unlock_email
    # Generate random token
    generate_token

    @employee.update(unlock_sent: true)
    @employee.update(unlock_token: @token)

    # Render Sync with external controller
    sync_update @employee

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country


    # Send SMS
    send_sms(@employee.phone, "BANP - #{t('views.mailer.greetings')} #{@employee.first_name}. #{t('views.mailer.unlock_account_link')}: #{admin_unlock_employee_account_url(unlock_token: @token)}")

    # Send email
    AuthenticationMailer.unlock_instructions(@employee, @token, I18n.locale, ip, location).deliver
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(unlock_token: @token).exists?
    end
  end

  # Save session information
  def session_info
    sign_in_count = @employee.sign_in_count
    sign_in_count += 1

    @employee.update(sign_in_count: sign_in_count)

    if @employee.last_sign_in_at.blank?
      @employee.update(last_sign_in_at: Time.zone.now)

    else
      @employee.update(last_sign_in_at: @employee.current_sign_in_at)
    end

    if @employee.last_sign_in_ip.blank?
      @employee.update(last_sign_in_ip: request.remote_ip)

    else
      @employee.update(last_sign_in_ip: @employee.current_sign_in_ip)
    end

    @employee.update(current_sign_in_at: Time.zone.now)
    @employee.update(current_sign_in_ip: request.remote_ip)

    # Render Sync with external controller
    sync_update @employee
  end

  # Reset failed attemps count
  def reset_attemps
    @employee.update(failed_attempts: 0)
    @employee.update(unlock_sent: false)

    # Render Sync with external controller
    sync_update @employee
  end

  # Increment failed attemps count
  def increment_attempts
    failed_attempts = @employee.failed_attempts
    failed_attempts += 1

    @employee.update(failed_attempts: failed_attempts)

    # Render Sync with external controller
    sync_update @employee

    failed_attempts
  end

  # /sign-out
  def destroy
    session[:employee_id] = nil
    session[:session_confirmed] = nil
    redirect_to admin_sign_in_path, notice: t("views.authentication.signed_out_correctly")
    return
  end
end
