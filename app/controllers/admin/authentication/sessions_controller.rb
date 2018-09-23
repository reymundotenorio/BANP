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
          session_info
          redirect_to admin_root_path, notice: "#{t('views.sign_in.incorrect_user_pwd')}*"
          # session[:user_id] = @employee.id

          # reset_attemps
          # session_info
          #     redirect_to dashboard_path, notice: "Bienvenido #{@employee.primer_nombre} #{@employee.primer_apellido}, ha iniciado sesión correctamente"
          #

          # If user exist but the password doesn't match
        else
          # increment_attempts
          redirect_to admin_root_path, alert: "#{t('views.sign_in.incorrect_user_pwd')}*"
        end

      end
      # If user doesn't exist
    else
      redirect_to admin_root_path, alert: t("views.sign_in.incorrect_user_pwd")
    end
  end

  # Validate if user is blocked
  def user_blocked?
    @max_failed_attempts = 5

    # If exceeded the number of failed attempts
    if @employee.failed_attempts >= @max_failed_attempts
      true

      # If not exceeded the number of failed attempts
    else
      false
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

  #
  # # Generar token
  # def generate_token
  #   loop do
  #     @token = SecureRandom.hex(15)
  #     break @token unless User.where(desbloqueo_token: @token).exists?
  #   end
  # end
end
