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
    product = Product.first

    address = params[:address] || @current_customer.address

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

    if charge
      # redirect_to charge.receipt_url
      redirect_to cart_path, notice: charge.receipt_url
      return
    else
    end

  end

  def dollars_to_cents(dollars)
    (100 * dollars.to_r).to_i
  end

  def payment
  end
end
