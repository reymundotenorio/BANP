class Admin::EmployeesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employees with Friendly_ID
  # before_action :set_employee, only: [:require_self, :show, :edit, :update, :active, :deactive, :history]
  before_action :set_employee, only: [:show, :edit, :update, :active, :deactive, :history]

  # End Find employees with Friendly_ID

  # Sync model DSL
  # enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  before_action :require_employee, :require_administrator
  skip_before_action :require_administrator, only: [:show, :edit, :history, :update]
  before_action :require_self, only: [:show, :edit, :history, :update]
  # End Authentication

  def require_self
    if current_employee.id != @employee.id && !current_employee.is_administrator?
      # clean_session
      redirect_to admin_root_path, alert: t("views.authentication.access_denied")
    end
  end

  # admin/employees
  def index
    @employees = Employee.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Employees with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @employees.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "employees-#{file_time}"
    template = "admin/employees/index_pdf.html.haml"
    title_pdf = t("header.navigation.employees")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Employee.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/employee/new
  def new
    @employee = Employee.new
  end

  # admin/employee/:id)
  def show
    # Employee found by before_action

    if @employee.role == "administrator"
      @employee.role = I18n.locale == :es ? "Administrador" : "Administrator"

    elsif @employee.role == "warehouse_supervisor"
      @employee.role = I18n.locale == :es ? "Supervisor de bodega" : "Warehouse supervisor"

    elsif @employee.role == "seller"
      @employee.role = I18n.locale == :es ? "Vendedor" : "Seller"

    elsif @employee.role == "driver"
      @employee.role = I18n.locale == :es ? "Conductor" : "Driver"

    elsif @employee.role == "chief_dispatch"
      @employee.role = I18n.locale == :es ? "Jefe de despacho" : "Chief dispatch"

    elsif @employee.role == "warehouse_assistant"
      @employee.role = I18n.locale == :es ? "Auxiliar de bodega" : "Warehouse assistant"
    end

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "employee-#{@employee.slug}-#{file_time}"
    template = "admin/employees/show_pdf.html.haml"
    title_pdf = t("activerecord.models.employee")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @employee, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/employee/:id/edit
  def edit
    # Employee found by before_action

    if @employee.role == "administrator"
      @employee.role = I18n.locale == :es ? "Administrador" : "Administrator"

    elsif @employee.role == "warehouse_supervisor"
      @employee.role = I18n.locale == :es ? "Supervisor de bodega" : "Warehouse supervisor"

    elsif @employee.role == "seller"
      @employee.role = I18n.locale == :es ? "Vendedor" : "Seller"

    elsif @employee.role == "driver"
      @employee.role = I18n.locale == :es ? "Conductor" : "Driver"

    elsif @employee.role == "chief_dispatch"
      @employee.role = I18n.locale == :es ? "Jefe de despacho" : "Chief dispatch"

    elsif @employee.role == "warehouse_assistant"
      @employee.role = I18n.locale == :es ? "Auxiliar de bodega" : "Warehouse assistant"
    end

  end

  # admin/employee/:id/history
  def history
    # Employee found by before_action

    @history = @employee.associated_audits
    @history.push(@employee.audits)
  end

  # Create
  def create
    @employee = Employee.new(employee_params)

    # Deleting blank spaces
    @employee[:first_name] = @employee[:first_name].strip
    @employee[:last_name] = @employee[:last_name].strip
    @employee[:email] =  @employee[:email].strip.downcase
    @employee[:phone] = @employee[:phone].strip
    @employee[:role] = @employee[:role].strip
    # End Deleting blank spaces

    if @employee[:role] == "Administrador" || @employee[:role] == "Administrator"
      @employee[:role] = "administrator"

    elsif @employee[:role] == "Supervisor de bodega" || @employee[:role] == "Warehouse supervisor"
      @employee[:role] = "warehouse_supervisor"

    elsif @employee[:role] == "Vendedor" || @employee[:role] == "Seller"
      @employee[:role] = "seller"

    elsif @employee[:role] == "Conductor" || @employee[:role] == "Driver"
      @employee[:role] = "driver"

    elsif @employee[:role] == "Jefe de despacho" || @employee[:role] == "Chief dispatch"
      @employee[:role] = "chief_dispatch"

    elsif @employee[:role] == "Auxiliar de bodega" || @employee[:role] == "Warehouse assistant"
      @employee[:role] = "warehouse_assistant"
    end

    # If record was saved
    if @employee.save
      sync_new @employee
      redirect_to [:admin, @employee], notice: t("alerts.created", model: t("activerecord.models.employee"))

      # If record was not saved
    else
      render :new
    end
  end

  # Update
  def update
    update_params = employee_params

    if update_params[:role] == "Administrador" || update_params[:role] == "Administrator"
      update_params[:role] = "administrator"

    elsif update_params[:role] == "Supervisor de bodega" || update_params[:role] == "Warehouse supervisor"
      update_params[:role] = "warehouse_supervisor"

    elsif update_params[:role] == "Vendedor" || update_params[:role] == "Seller"
      update_params[:role] = "seller"

    elsif update_params[:role] == "Conductor" || update_params[:role] == "Driver"
      update_params[:role] = "driver"

    elsif update_params[:role] == "Jefe de despacho" || update_params[:role] == "Chief dispatch"
      update_params[:role] = "chief_dispatch"

    elsif update_params[:role] == "Auxiliar de bodega" || update_params[:role] == "Warehouse assistant"
      update_params[:role] = "warehouse_assistant"
    end

    if @employee.update(update_params)
      sync_update @employee
      redirect_to [:admin, @employee], notice: t("alerts.updated", model: t("activerecord.models.employee"))

    else
      render :edit
    end
  end

  # Active
  def active
    if @employee.update(state: true)
      sync_update @employee

      redirect_to admin_employee_path(@employee), notice: t("alerts.enabled", model: t("activerecord.models.employee"))

    else
      redirect_to admin_employee_path(@employee), alert: t("alerts.not_enabled", model: t("activerecord.models.employee"))
    end
  end

  # Deactive
  def deactive
    if @employee.update(state: false)
      sync_update @employee

      redirect_to admin_employee_path(@employee), notice: t("alerts.disabled", model: t("activerecord.models.employee"))

    else
      redirect_to admin_employee_path(@employee), alert: t("alerts.not_disabled", model: t("activerecord.models.employee"))
    end
  end

  private

  # Set Employee
  def set_employee
    @employee = Employee.friendly.find(params[:id])

  rescue
    redirect_to admin_employees_path, alert: t("alerts.not_found", model: t("activerecord.models.employee"))
  end

  # Employee params
  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :email, :phone, :role, :image)
  end
end
