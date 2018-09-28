class Admin::Authentication::ConfirmationsController < ApplicationController
  def new
  end

  # /confirm-employee-account/:confirmation_token
  def show
    @token = params[:confirmation_token]

    if @employee = Employee.find_by(confirmation_token: @token)

      # If user is enabled
      if @employee.state

        # If user is not confirmed yet
        if !@employee.confirmed
          @employee.update_attribute(:confirmed, true)

          # Render Sync with external controller
          sync_update @employee

          redirect_to admin_sign_in_path, notice: "Su cuenta #{@employee.email} ha sido confirmada con éxito. Ahora puede iniciar sesión"

          # If user is already confirmed
        else
          redirect_to admin_sign_in_path, notice: "Su cuenta #{@employee.email} se encuentra confirmada"
        end

        # If user is disabled
      else
        redirect_to admin_sign_in_path, alert: 'No puede confirmar su cuenta, ésta ha sido desactivada. Comuníquese con el Administrador para solucionar este inconveniente'
      end
    else
      redirect_to admin_sign_in_path, alert: "El código de confirmación #{@token} no ha sido encontrado en el sistema"
    end
  end
end
