class Admin::Authentication::SessionsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /sign-in
  def new
    hide_message = params[:hide_message]

    if hide_message
      @hide_message = true

    else
      @hide_message = false
    end
  end

  # Sign in
  def create
    @employee = Employee.find_by(email: params[:sign_in][:email])
    max_failed_attempts = 4

    # If user exists
    if @employee

      # If user is enabled
      if @employee.state

        # If user is confirmed
        if @employee.confirmed

          # If user is locked
          if user_locked?(max_failed_attempts)
            redirect_to admin_unlock_account_path(email: @employee.email), alert: t("views.authentication.account_locked", email: @employee.email)

            # If user is not locked
          else
            # If user exist and password matches
            if @employee && @employee.authenticate(params[:sign_in][:password])
              session[:employee_id] = @employee.id
              session_info
              reset_attemps

              redirect_to admin_employees_path, notice: t("views.authentication.signed_in_correctly", first_name: @employee.first_name, last_name: @employee.last_name)

              # If user exist but the password doesn't match
            else
              remaining_attempts = max_failed_attempts - increment_attempts
              remaining_attempts += 1

              flash[:alert] = "#{t('views.authentication.incorrect_pwd')}, #{remaining_attempts} #{remaining_attempts == 1 ? t('views.authentication.remaining_attempt') : t('views.authentication.remaining_attempts')}"
              render :new
            end
          end

          # If user is not confirmed
        else
          redirect_to admin_confirm_account_path(email: @employee.email), alert: t("views.authentication.account_not_confirmed_resend", email: @employee.email)
        end

        # If user is disabled
      else
        flash[:alert] = t("views.authentication.account_disabled", email: @employee.email)
        render :new
      end
      # If user doesn't exist
    else
      flash[:alert] = t("views.authentication.incorrect_user_pwd")
      render :new
    end
  end

  # Validate if user is locked
  def user_locked?(max_failed_attempts)
    # If exceeded the number of failed attempts
    if @employee.failed_attempts >= max_failed_attempts
      # If unlock email has been sent
      if @employee.unlock_sent
        true

        # If unlock email has not been sent
      else
        send_unlock_email
        true
      end

      # If not exceeded the number of failed attempts
    else
      false
    end
  end

  # Send unlock email to the user
  def send_unlock_email
    # Generate random token
    generate_token

    @employee.update_attribute(:unlock_sent, true)
    @employee.update_attribute(:unlock_token, @token)

    # Render Sync with external controller
    sync_update @employee

    # Send email
    AuthenticationMailer.unlock_instructions(@employee, @token, I18n.locale).deliver
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

    @employee.update_attribute(:sign_in_count, sign_in_count)

    if @employee.last_sign_in_at.blank?
      @employee.update_attribute(:last_sign_in_at, Time.zone.now)

    else
      @employee.update_attribute(:last_sign_in_at, @employee.current_sign_in_at)
    end

    if @employee.last_sign_in_ip.blank?
      @employee.update_attribute(:last_sign_in_ip, request.remote_ip)

    else
      @employee.update_attribute(:last_sign_in_ip, @employee.current_sign_in_ip)
    end

    @employee.update_attribute(:current_sign_in_at, Time.zone.now)
    @employee.update_attribute(:current_sign_in_ip, request.remote_ip)

    # Render Sync with external controller
    sync_update @employee
  end

  # Reset failed attemps count
  def reset_attemps
    @employee.update_attribute(:failed_attempts, 0)
    @employee.update_attribute(:unlock_sent, false)

    # Render Sync with external controller
    sync_update @employee
  end

  # Increment failed attemps count
  def increment_attempts
    failed_attempts = @employee.failed_attempts
    failed_attempts += 1

    @employee.update_attribute(:failed_attempts, failed_attempts)

    # Render Sync with external controller
    sync_update @employee

    failed_attempts
  end

  # Sign out
  def destroy
    session[:employee_id] = nil
    flash[:notice] = t("views.authentication.signed_out_correctly")
    render :new
  end
end
