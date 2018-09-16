class Admin::Authentication::SessionsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /sign-in
  def new
  end

  # Iniciar sesión
  def create
    @employee = Employee.find_by(email: params[:sign_in][:email])

    if user_block?
      # If employee account is blocked
      block_user
    else
      # If employee account is not blocked
      if @employee && @employee.authenticate(params[:sign_in][:password])

        # Si el usuario existe y contraseña coincide
        session[:user_id] = @employee.id
        reset_attemps
        session_info
        redirect_to dashboard_path, notice: "Bienvenido #{@employee.primer_nombre} #{@employee.primer_apellido}, ha iniciado sesión correctamente"
      elsif @employee
        # Si el usuario existe, pero contraseña no coincide
        increment_attempts
      else # Usuario no existe
        flash[:alert] = "Correo electrónico y/o contraseña inválidos"
        render :new
      end

    end
  end


  # Generar token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless User.where(desbloqueo_token: @token).exists?
    end
  end


  # Guardar información de la sesión
  def session_info
    cantidad_sesion = @employee.inicio_sesion_cantidad
    cantidad_sesion += 1
    @employee.update_attribute(:inicio_sesion_cantidad, cantidad_sesion)
    @employee.update_attribute(:inicio_sesion_actual_a_las, Time.now)
    @employee.update_attribute(:inicio_sesion_actual_ip, request.remote_ip)
  end
end
