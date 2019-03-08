class Admin::ReportsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee, :require_administrator
  # End Authentication

  def sales
    @search_form_path = admin_reports_sales_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
    @employees = Employee.search(params[:search_employee], "enabled-only").paginate(page: params[:employees_page], per_page: 5) # Products with pagination
  end

  def purchases
    @search_form_path = admin_reports_purchases_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
    @employees = Employee.search(params[:search_employee], "enabled-only").paginate(page: params[:employees_page], per_page: 5) # Products with pagination
  end

  def sales_report
    # @params = params

    if !params[:from_datetime]
      redirect_to admin_reports_sales_path, alert: t("charts.select_start_date")
      return
    end

    if !params[:to_datetime]
      redirect_to admin_reports_sales_path, alert: t("charts.select_end_date")
      returnñ
    end

    from_datetime = params[:from_datetime] = params[:from_datetime].to_datetime if params[:from_datetime]
    to_datetime = params[:to_datetime] = params[:to_datetime].to_datetime if params[:to_datetime]

    report_customer_id = params[:report_customer_id].to_i || nil
    report_product_id = params[:report_product_id].to_i || nil
    report_employee_id = params[:report_employee_id].to_i || nil

    join_customer = "JOIN customers ON sales.customer_id = customers.id"
    join_employee = "JOIN employees ON sales.employee_id = employees.id"
    join_category = "JOIN categories ON products.category_id = categories.id"
    where_dates_range = "sales.sale_datetime BETWEEN :from_datetime AND :to_datetime"
    where_paid_enabled = "(sales.paid = true) AND (sales.state = true)"
    order_datetime = "sales.sale_datetime"

    @sales = SaleDetail.joins(:sale).joins(:product).joins(join_category).joins(join_customer).joins(join_employee).where(where_dates_range, from_datetime: from_datetime, to_datetime: to_datetime).where(where_paid_enabled)

    if report_customer_id && report_customer_id != 0
      @sales = @sales.where("sales.customer_id = :report_customer_id", report_customer_id: report_customer_id)
    end

    if report_product_id && report_product_id != 0
      @sales = @sales.where("sale_details.product_id = :report_product_id", report_product_id: report_product_id)
    end

    if report_employee_id && report_employee_id != 0
      @sales = @sales.where("sales.employee_id = :report_employee_id", report_employee_id: report_employee_id)
    end

    @sales = @sales.order(order_datetime).not_returned.not_pending.paginate(page: params[:page], per_page: 50)

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sales-report-#{file_time}"
    template = "admin/reports/sales_report_pdf.html.haml"
    # End PDF view configuration

    @start_date = I18n.locale == :es ? from_datetime.strftime("%d/%m/%Y") : from_datetime.strftime("%m/%d/%Y")
    @end_date = I18n.locale == :es ? to_datetime.strftime("%d/%m/%Y") : to_datetime.strftime("%m/%d/%Y")

    title_pdf = "#{t('charts.sales_report')} (#{@start_date} - #{@end_date})"

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf_landscape(name_pdf, template, @sales, I18n.l(datetime), title_pdf)
      end
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=sales-report-#{file_time}.xlsx"
      end
    end
  end

  def purchases_report
    # @params = params

    if !params[:from_datetime]
      redirect_to admin_reports_purchases_path, alert: t("charts.select_start_date")
      return
    end

    if !params[:to_datetime]
      redirect_to admin_reports_purchases_path, alert: t("charts.select_end_date")
      returnñ
    end

    from_datetime = params[:from_datetime] = params[:from_datetime].to_datetime if params[:from_datetime]
    to_datetime = params[:to_datetime] = params[:to_datetime].to_datetime if params[:to_datetime]

    report_provider_id = params[:report_provider_id].to_i || nil
    report_product_id = params[:report_product_id].to_i || nil
    report_employee_id = params[:report_employee_id].to_i || nil

    join_provider = "JOIN providers ON purchases.provider_id = providers.id"
    join_employee = "JOIN employees ON purchases.employee_id = employees.id"
    join_category = "JOIN categories ON products.category_id = categories.id"
    where_dates_range = "purchases.purchase_datetime BETWEEN :from_datetime AND :to_datetime"
    where_enabled = "purchases.state = true"
    order_datetime = "purchases.purchase_datetime"

    @purchases = PurchaseDetail.joins(:purchase).joins(:product).joins(join_category).joins(join_provider).joins(join_employee).where(where_dates_range, from_datetime: from_datetime, to_datetime: to_datetime).where(where_enabled)

    if report_provider_id && report_provider_id != 0
      @purchases = @purchases.where("purchases.provider_id = :report_provider_id", report_provider_id: report_provider_id)
    end

    if report_product_id && report_product_id != 0
      @purchases = @purchases.where("purchase_details.product_id = :report_product_id", report_product_id: report_product_id)
    end

    if report_employee_id && report_employee_id != 0
      @purchases = @purchases.where("purchases.employee_id = :report_employee_id", report_employee_id: report_employee_id)
    end

    @purchases = @purchases.order(order_datetime).not_returned.paginate(page: params[:page], per_page: 50)

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchases-report-#{file_time}"
    template = "admin/reports/purchases_report_pdf.html.haml"
    # End PDF view configuration

    @start_date = I18n.locale == :es ? from_datetime.strftime("%d/%m/%Y") : from_datetime.strftime("%m/%d/%Y")
    @end_date = I18n.locale == :es ? to_datetime.strftime("%d/%m/%Y") : to_datetime.strftime("%m/%d/%Y")

    title_pdf = "#{t('charts.purchases_report')} (#{@start_date} - #{@end_date})"

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf_landscape(name_pdf, template, @purchases, I18n.l(datetime), title_pdf)
      end
      format.xlsx do
        response.headers['Content-Disposition'] = "attachment; filename=purchases-report-#{file_time}.xlsx"
      end
    end
  end
end
