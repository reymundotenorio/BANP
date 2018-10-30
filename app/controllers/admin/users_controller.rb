class Admin::UsersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employees with Friendly_ID
  before_action :set_employee, only: [:new_employee_user, :create_employee_user]
  # End Find employees with Friendly_ID

  def new_employee_user
    @user = User.new
  end

  def create_employee_user
    @user = User.new(user_params)

    # If record was saved
    if @user.save
      redirect_to [:admin, @employee], notice: "Usuario creado"

      # If record was not saved
    else
      render :new_employee_user
    end
  end

  private

  # Set Employee
  def set_employee
    @employee = Employee.friendly.find(params[:id])
  rescue
    redirect_to admin_employees_path, alert: "No se pudo encontrar"
  end

  # User params
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
