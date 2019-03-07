class Admin::ReportsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee
  # End Authentication

  def sales
    @search_form_path = admin_create_reports_sales_path(@invoice)

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
    @employees = Employee.search(params[:search_employee], "enabled-only").paginate(page: params[:employees_page], per_page: 5) # Products with pagination
  end

  def sales_report
    puts "#{params}".red

    if !params[:from_datetime]
      redirect_to admin_reports_sales_path, alert: "Debe seleccionar fecha de inicio"
      return
    end

    if !params[:to_datetime]
      redirect_to admin_reports_sales_path, alert: "Debe seleccionar fecha final"
      return
    end

    from_datetime = params[:from_datetime] = params[:from_datetime].to_datetime if params[:from_datetime]
    to_datetime = params[:to_datetime] = params[:to_datetime].to_datetime if params[:to_datetime]


    report_customer_id = params[:report_customer_id].to_i || nil
    report_product_id = params[:report_product_id].to_i || nil
    report_employee_id = params[:report_employee_id].to_i || nil

    if report_customer_id
    end

    if report_product_id
    end

    if report_employee_id
    end

    # consult = ""
    #
    # consult += "( sales.sale_datetime BETWEEN NOW() - INTERVAL 12 MONTH AND NOW() ) AND (sales.paid = true)"

    @sales = SaleDetail.joins(:sale).joins(:product).joins("JOIN customers ON sales.customer_id = customers.id").joins("JOIN employees ON sales.employee_id = employees.id").where("sales.sale_datetime BETWEEN NOW() - INTERVAL 2 MONTH AND NOW()").not_returned.not_pending.paginate(page: params[:page], per_page: 50)

    # , product_id: product_id, customer_id: customer_id, employee_id: employee_id).not_returned.not_pending

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "reports-sales-#{file_time}"
    template = "admin/reports/sales_report_pdf.html.haml"
    title_pdf = t("header.navigation.sales")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, @sales, I18n.l(datetime), title_pdf)
      end
    end

  end

  def purchases
  end
end
