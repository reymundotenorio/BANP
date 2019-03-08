class Admin::SaleDetailsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find sale
  before_action :set_sale, only: [:show]
  # End Find sale

  # Authentication
  before_action :require_employee, :require_seller_driver
  # End Authentication

  def show
    @is_invoice = @sale.status == "invoiced" ? true : false
    @is_shipment = @sale.status == "shipped" ? true : false
    @is_delivery = @sale.status == "delivered" ? true : false

    if @is_invoice
      @details =  SaleDetail.search_invoices(@sale.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15)

    elsif @is_shipment
      @details = SaleDetail.search_shipments(@sale.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Details with pagination

    elsif @is_delivery
      @details = SaleDetail.search_deliveries(@sale.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Details with pagination

    else
      @details = SaleDetail.search_orders(@sale.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Details with pagination
    end

    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @details.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-details-#{file_time}"
    # template = "admin/sale_details/show_pdf.html.haml"

    if @is_invoice
      title_pdf = "#{t('sale.invoice_details')} ##{@sale.id}"

    elsif @is_shipment
      title_pdf = "#{t('sale.shipment_details')} ##{@sale.id}"

    elsif @is_delivery
      title_pdf = "#{t('sale.delivery_details')} ##{@sale.id}"

    else
      title_pdf = "#{t('sale.order_details')} ##{@sale.id}"
    end
    # End PDF view configuration

    @invoice_no = @sale.id
    @invoice_date = @sale.sale_datetime
    template = "partials/invoice.html.haml"

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        # to_pdf(name_pdf, template, @details, I18n.l(datetime), title_pdf)
        invoice_pdf(name_pdf, template, @sale, I18n.l(datetime), title_pdf)
      end
    end
  end

  private

  # Set Sale
  def set_sale
    @sale = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_orders_path, alert: t("alerts.not_found", model: t("activerecord.models.sale"))
  end
end
