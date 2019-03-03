class Admin::SaleDetailsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find sale
  before_action :set_sale, only: [:show]
  # End Find sale

  # Authentication
  # before_action :require_employee
  # End Authentication

  def show
    @is_invoice = @sale.status == "invoiced" ? true : false

    @details = @is_invoice ? SaleDetail.search_invoices(@sale.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) : SaleDetail.search_orders(@sale.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Details with pagination

    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @details.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-details-#{file_time}"
    template = "admin/sale_details/show_pdf.html.haml"
    title_pdf =   @is_invoice ? "#{t('sale.invoice_details')} ##{@sale.id}" : "#{t('sale.order_details')} ##{@sale.id}"
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, @details, I18n.l(datetime), title_pdf)
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
