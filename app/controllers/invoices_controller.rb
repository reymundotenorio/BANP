class InvoicesController < ApplicationController

  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Find sale
  before_action :set_sale, only: [:show]
  # End Find sale

  # Authentication
  before_action :require_customer
  # End Authentication

  def show
    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "BANP-invoice-#{@sale.id}-#{file_time}"
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
      format.pdf do
        # to_pdf(name_pdf, template, @details, I18n.l(datetime), title_pdf)
        invoice_pdf_download(name_pdf, template, @sale, I18n.l(datetime), title_pdf)
      end
    end
  end

  private

  # Set Sale
  def set_sale
    @sale = Sale.find(params[:id])

  rescue
    redirect_to root_orders_path, alert: t("alerts.not_found", model: t("activerecord.models.sale"))
  end
end
