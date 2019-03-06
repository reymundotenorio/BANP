class TrackingsController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Find sale order with Friendly_ID
  before_action :set_sale_order, only: [:show]
  # End Find sale order with Friendly_ID

  # Authentication
  before_action :require_customer
  # End Authentication

  # /orders
  def index
    @orders = Sale.search_order_ecommerce(params[:search], current_customer.id).paginate(page: params[:page], per_page: 15) # Orders with pagination

    # @orders = Sale.search_invoice(params[:all], params[:search]).paginate(page: params[:page], per_page: 15) # Orders with pagination

    @count = @orders.count
    @customer_id = current_customer.id

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @history = @order.associated_audits
    @history.push(@order.audits)
  end

  private

  # Set Sale
  def set_sale_order
    @order = Sale.find(params[:id])

  rescue
    redirect_to root_path, alert: t("alerts.not_found", model: t("sale.order"))
  end
end
