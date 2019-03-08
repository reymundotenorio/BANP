class Admin::PurchaseDetailsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find purchase
  before_action :set_purchase, only: [:show]
  # End Find purchase

  # Authentication
  before_action :require_employee, :require_warehouse_supervisor
  # End Authentication

  def show
    @is_reception = @purchase.status == "received" ? true : false

    @details = @is_reception ? PurchaseDetail.search_receptions(@purchase.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) : PurchaseDetail.search_orders(@purchase.id, params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Details with pagination


    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @details.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchase-details-#{file_time}"
    template = "admin/purchase_details/show_pdf.html.haml"
    title_pdf =   @is_reception ? "#{t('purchase.reception_details')} ##{@purchase.receipt_number}" : "#{t('purchase.order_details')} ##{@purchase.receipt_number}"
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

  # Set Purchase
  def set_purchase
    @purchase = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_orders_path, alert: t("alerts.not_found", model: t("activerecord.models.purchase"))
  end
end
