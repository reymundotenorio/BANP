class Admin::EmployeesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find employees with Friendly_ID
  before_action :set_employee, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find employees with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive, :send_confirmation_email]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee, only: [:index, :show, :new, :create, :edit, :update, :active, :deactive, :history]
  before_action :require_employee
  # End Authentication

  # /employees
  def index
    @employees = Employee.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Employees with pagination

    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)

    current_lang = params[:lang]

    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "employees-#{file_time}"
    template = "admin/employees/index_pdf.html.erb"
    title_pdf = t("header.navigation.employees")

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Employee.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # /employee/new
  def new
    @employee = Employee.new
  end

  # /employee/:id)
  def show
    # Employee found by before_filter

    current_lang = params[:lang]

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "employee-#{@employee.slug}-#{file_time}"
    template = "admin/employees/show_pdf.html.erb"
    title_pdf = t("activerecord.models.employee")

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @employee, I18n.l(datetime), title_pdf)
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
    @employee[:first_name] = @employee[:first_name].strip
    @employee[:last_name]= @employee[:last_name].strip
    @employee[:phone] = @employee[:phone].strip
    @employee[:role] = @employee[:role].strip
    @employee[:email] =  @employee[:email].strip.downcase
    # End Deleting blank spaces

    # Adding default values on blank? (nil or "")
    # @employee[:state] = true if @employee[:state].blank?

    # If record was saved
    if @employee.save
      send_confirmation_email
      redirect_to [:admin, @employee], notice: "#{t('alerts.created', model: t('activerecord.models.employee'))}. #{t('views.authentication.account_not_confirmed', email: @employee.email)}"

      # If record was not saved
    else
      render :new
    end
  end

  # Send unlock email to the user
  def send_confirmation_email
    # Generate random token
    generate_token

    @employee.update_attribute(:confirmation_sent, true)
    @employee.update_attribute(:confirmation_token, @token)

    ip = request.remote_ip
    location = Geocoder.search(ip).first.country

    # Send email
    AuthenticationMailer.confirmation_instructions(@employee, @token, I18n.locale, ip, location).deliver
  end

  # Generate token
  def generate_token
    loop do
      @token = SecureRandom.hex(15)
      break @token unless Employee.where(confirmation_token: @token).exists?
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
    if @employee.update(state: true)
      redirect_to_back(true, admin_employees_path, "employee", "success")

    else
      redirect_to_back(true, admin_employees_path, "employee", "error")
    end
  end

  # Deactive
  def deactive
    if @employee.update(state: false)
      redirect_to_back(false, admin_employees_path, "employee", "success")

    else
      redirect_to_back(false, admin_employees_path, "employee", "error")
    end
  end

  private

  # Set Employee
  def set_employee
    @employee = Employee.friendly.find(params[:id])
  rescue
    render :index
  end

  # Employee params
  def employee_params
    params.require(:employee).permit(:first_name, :last_name, :phone, :role, :email, :password, :password_confirmation, :image)
  end
end
