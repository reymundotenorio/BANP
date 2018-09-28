class Admin::Authentication::ConfirmationsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout
  
  def new
  end

  # /confirm-employee-account/:confirmation_token
  def show
    @token = params[:confirmation_token]

      # If token has been found
    if @employee = Employee.find_by(confirmation_token: @token)

      # If user is enabled
      if @employee.state

        # If user is not confirmed yet
        if !@employee.confirmed
          @employee.update_attribute(:confirmed, true)

          # Render Sync with external controller
          sync_update @employee

          redirect_to admin_sign_in_path, notice: "#{t('views.authentication.successfully_confirmed', @employee.email)}"

          # If user is already confirmed
        else
          redirect_to admin_sign_in_path, notice: "#{t('views.authentication.account_confirmed', @employee.email)}"
        end

        # If user is disabled
      else
        redirect_to admin_sign_in_path, alert: "#{t('views.authentication.account_disabled')}"
      end
      
      # If token has not been found
    else
      redirect_to admin_sign_in_path, alert: "#{t('views.authentication.token_not_found', @token)}"
    end
  end
end
