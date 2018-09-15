class Admin::EmployeesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employees with Friendly_ID
  before_action :set_employee, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find employees with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active_deactive]
  # End Sync model DSL

  # Authentication
  #  before_action :require_admin, only: [:index, :show, :new, :create, :edit, :update, :active_deactive, :history]
  # End Authentication

  # /employees
  def index
    @employees = Employee.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Employees with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)

    current_lang = params[:lang]

    I18n.locale = current_lang
    datetime = I18n.l Time.now

    file_time = Time.now.strftime("%m%d%Y")

    name_pdf = "employees-#{file_time}"
    template = "admin/employees/index_pdf.html.erb"
    title_pdf = t("header.navigation.employees")

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, Employee.all, datetime, title_pdf)
      end
    end
  end

  # /employee/new
  def new
    @employee = Employee.new
  end

  # /employee/:id
  def show
    # Employee found by before_filter

    current_lang = params[:lang]

    I18n.locale = current_lang
    datetime = I18n.l Time.now

    file_time = Time.now.strftime("%m%d%Y")

    name_pdf = "employee-#{@employee.slug}-#{file_time}"
    template = "admin/employees/show_pdf.html.erb"
    title_pdf = t("activerecord.models.employee")

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @employee, datetime, title_pdf)
      end
    end
  end

  # /employee/:id/edit
  def edit
    # Employee found by before_filter
  end

  # /employee/:id/history
  def history
    # Employee found by before_filter
  end

  # Create
  def create
    @employee = Employee.new(employee_params)

    # Deleting blank spaces
    @employee[:first_name].strip!
    @employee[:last_name].strip!
    @employee[:phone].strip!
    @employee[:role].strip!
    @employee[:email].strip.downcase!
    # End Deleting blank spaces

    # Adding default values on blank? (nil or "")
    # @employee[:state] = true if @employee[:state].blank?

    if @employee.save
      redirect_to [:admin, @employee], notice: t("alerts.created", model: t("activerecord.models.employee"))
    else
      render :new
    end
  end

  # Update
  def update
    if @employee.update(employee_params)
      redirect_to [:admin, @employee], notice: t("alerts.updated", model: t("activerecord.models.employee"))
    else
      render :edit
    end
  end

  # Active
  def active
    if @employee.update_attributes(state: true)
      redirect_to_back_success true
    else
      redirect_to_back_error true
    end
  end

  # Deactive
  def deactive
    if @employee.update_attributes(state: false)
      redirect_to_back_success false
    else
      redirect_to_back_error false
    end
  end

  # Redirect to back with success
  def redirect_to_back_success(state)
    if state
      redirect_back fallback_location: admin_employees_path, notice: t("alerts.enabled", model: t("activerecord.models.employee"))
    else
      redirect_back fallback_location: admin_employees_path, notice: t("alerts.disabled", model: t("activerecord.models.employee"))
    end
  end

  # Redirect to back with error
  def redirect_to_back_error(state)
    if state
      redirect_back fallback_location: admin_employees_path, alert: t("alerts.not_enabled", model: t("activerecord.models.employee"))
    else
      redirect_back fallback_location: admin_employees_path, alert: t("alerts.not_disabled", model: t("activerecord.models.employee"))
    end
  end

  private

  # Set Employee
  def set_employee
    @employee = Employee.friendly.find(params[:id])
  rescue
    render_404 # Located on Application controller
  end

  # Employee params
  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :phone, :role, :email, :password, :password_confirmation, :image)
  end
end
