class Admin::UsersController < ApplicationController

  # Find employees with Friendly_ID
  before_action :set_employee, only: [:new_user_employee, :create_user_employee]
  # End Find employees with Friendly_ID

  def new_user_employee
    @user = User.new
  end

  def create_user_employee
    @user = User.new(user_params)

    # If record was saved
    if @user.save
      redirect_to [:admin, @employee], notice: "Usuario creado"

      # If record was not saved
    else
      render :new_user_employee
    end
  end

  private

  # Set Employee
  def set_employee
    @employee = Employee.friendly.find(params[:employee_id])
  rescue
    redirect_to admin_employees_path, alert: "No se pudo encontrar"
  end

  # User params
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
