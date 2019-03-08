class PayUponDeliveryController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Authentication
  before_action :require_customer
  # End Authentication

  def checkout
    address = params[:address] || current_customer.address

    # Creating the order
    order = Sale.new

    order.sale_datetime = Time.current
    order.status = "pending"
    order.delivery_status = "in_queue"
    order.discount = 0.00
    order.customer_id = current_customer.id
    order.employee_id = 1 # SIBANP
    order.observations = address

    order.payment_method = "Cash"
    order.payment_reference = "-"
    order.paid = false

    # Iterating products
    params[:products].each do |id, attributes|
      cart_product = Product.find(attributes["id"].to_i)

      if cart_product
        order.sale_details.build(product_id: cart_product.id, price: cart_product.price, quantity: attributes["quantity"].to_i, status: "ordered")
      end
    end
    # End Iterating products

    # If order was saved correcty
    if order.save
      sync_new order

      notification = Notification.new
      notification.message = "new_order"
      notification.path = "#{admin_sale_details_url(order.id)}"
      notification.read_by = "false"

      if notification.save
        puts "Notification saved"
        sync_new notification

      else
        puts "Notification not saved"
      end

      redirect_to tracking_path(order.id, clean_cart: "clean-all"), notice: t("views.cart.payment_correctly")
      return
      
      # If order was not saved correcty
    else
      errors_messages = ""

      order.errors.full_messages.each do |error|
        errors_messages += " #{error}."
      end

      errors_messages = errors_messages.strip

      redirect_to cart_path, alert: errors_messages
      return
    end
    # End Creating the order
  end


  def payment
  end
end
