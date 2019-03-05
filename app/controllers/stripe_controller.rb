class StripeController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Authentication
  before_action :require_customer
  # End Authentication

  def checkout
    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here: https://dashboard.stripe.com/account/apikeys
    Stripe.api_key = "#{ENV["stripe_secret_key"]}"

    # Token is created using Checkout or Elements!
    # Get the payment token ID submitted by the form
    token = params[:stripeToken]
    address = params[:address] || current_customer.address

    product_items = Array.new
    products_description = ""

    params[:products].each do |id, attributes|
      product = Product.find(attributes["id"].to_i)

      item =
      {
        name: I18n.locale == :es ? "#{product.name} (#{attributes['quantity']})" : "#{product.name_spanish} (#{attributes['quantity']})",
        price: "#{product.price}",
        quantity: attributes["quantity"]
      }

      product_items.push(item)

      if id == "1"
        products_description = I18n.locale == :es ? "#{product.name} (#{attributes['quantity']})" : "#{product.name_spanish} (#{attributes['quantity']})"

      else
        products_description += ", "
        products_description += I18n.locale == :es ? "#{product.name} (#{attributes['quantity']})" : "#{product.name_spanish} (#{attributes['quantity']})"
      end
    end

    # Calculations
    items_subtotal = product_items.inject(0) {|sum, hash| sum + ((hash[:price]).to_f * (hash[:quantity]).to_i)}
    items_subtotal = items_subtotal.round(2)

    # Fixing price
    price_cents = dollars_to_cents(items_subtotal.to_s)

    # Creating the order
    order = Sale.new

    order.sale_datetime = Time.current
    order.status = "pending"
    order.delivery_status = "in_queue"
    order.discount = 0.00
    order.customer_id = current_customer.id
    order.employee_id = 1 # SIBANP
    order.observations = address

    order.payment_method = "Stripe"
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

      # Creating charge
      begin

        charge = Stripe::Charge.create(
        {
          amount: price_cents,
          currency: "usd",
          description: products_description,
          source: token,
        }
        )

      rescue Stripe::InvalidRequestError => e
        redirect_to cart_path, alert: e.message
        return
      end
      # End Creating charge

      # If charge was create correctly
      if charge
        order.status = "ordered"
        order.payment_reference = charge.id
        order.paid = true

        if order.save
          sync_update order
          redirect_to cart_path, notice: "Orden generada correctamente"
          return

        else
          redirect_to cart_path, error: "Error al generar orden"
          return
        end
      end
      # End If charge was create correctly

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

  def dollars_to_cents(dollars)
    (100 * dollars.to_r).to_i
  end

  def payment
  end
end
