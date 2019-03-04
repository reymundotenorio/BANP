class Admin::Sales::OrdersController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find sale order with Friendly_ID
  before_action :set_sale_order, only: [:show, :history]
  # End Find sale order with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # /admin/sales/orders
  def index
    @orders = Sale.search_order(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @orders.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-orders-#{file_time}"
    template = "admin/sales/orders/index_pdf.html.haml"
    title_pdf = t("sale.orders")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Sale.orders, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/order/:id/history
  def history
    # Employee found by before_action

    @history = @order.associated_audits
    @history.push(@order.audits)
  end

  private

  # Set Sale
  def set_sale_order
    @order = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_orders_path, alert: t("alerts.not_found", model: t("sale.order"))
  end
end
