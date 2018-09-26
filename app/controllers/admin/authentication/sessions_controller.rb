class Admin::Authentication::SessionsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /sign-in
  def new
  end

  # Sign in
  def create
    @employee = Employee.find_by(email: params[:sign_in][:email])

    # If user exists
    if @employee
      # If user is blocked
      if user_blocked?
        # Redirect to unlock_account

        # If user is not blocked
      else

        # If user exist and password matches
        if @employee && @employee.authenticate(params[:sign_in][:password])
          session[:user_id] = @employee.id
          session_info
          reset_attemps
    
          redirect_to admin_employees_path, notice: "Bienvenido #{@employee.first_name} #{@employee.last_name}, ha iniciado sesión correctamente"

          # If user exist but the password doesn't match
        else
          increment_attempts
          redirect_to admin_root_path, alert: "#{t('views.sign_in.incorrect_pwd')}, #{count == 1 ? t('views.sign_in.remaining_attempt') : t('views.sign_in.remaining_attempts')}"
        end

      end
      # If user doesn't exist
    else
      redirect_to admin_root_path, alert: t("views.sign_in.incorrect_user_pwd")
    end
  end

  # Validate if user is blocked
  def user_blocked?
    max_failed_attempts = 5

    # If exceeded the number of failed attempts
    if @employee.failed_attempts >= max_failed_attempts
      # If unlock email has been sent
      if @employee.unlock_sent


        # If unlock email has not been sent
      else
        send_unlock_email
      end

      true

      # If not exceeded the number of failed attempts
    else
      false
    end
  end

  # Send unlock email to the user
  def send_unlock_email
    generate_token

    @employee.update_attribute(:unlock_sent, true)
    @employee.update_attribute(:unlock_token, @token)
    # AuthenticationMailer.unlock_instructions(@employee, @token).deliver
    AuthenticationMailer.confirmation_instructions(@employee, @token, I18n.locale).deliver
  end

  # Generate token
  def generate_token
    #loop do
      @token = SecureRandom.hex(15)
      #break @token unless Employee.where(unlock_token: @token).exists?
    #end
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
  end
  
    # Increment failed attemps count
  def increment_attempts
  failed_attempts = @employee.failed_attempts
    failed_attempts += 1
    
    @employee.update_attribute(:failed_attempts, failed_attempts)
    return
  end
end
