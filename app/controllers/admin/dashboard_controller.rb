class Admin::DashboardController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee
  # End Authentication

  def index
    redirect_per_role(flash[:notice], flash[:alert])
  end

  # Redirection per employee role
  def redirect_per_role(notice_message, alert_message)
    # If employee is a seller
    if current_employee.is_seller?
      redirect_to admin_sale_invoices_path, notice: notice_message, alert: alert_message
      return

      # If employee is a driver
    elsif current_employee.is_driver?
      redirect_to admin_sale_shipments_path, notice: notice_message, alert: alert_message
      return

      # If employee is a warehouse supervisor
    elsif current_employee.is_warehouse_supervisor?
      redirect_to admin_purchase_orders_path, notice: notice_message, alert: alert_message
      return

      # If employee is a other role (administrator)
    else
      return
    end
    # End If employee is a seller
  end
end
