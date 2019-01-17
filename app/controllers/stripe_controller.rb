class StripeController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  def checkout
    # Set your secret key: remember to change this to your live secret key in production
    # See your keys here: https://dashboard.stripe.com/account/apikeys
    Stripe.api_key = "#{ENV["stripe_secret_key"]}"

    # Token is created using Checkout or Elements!
    # Get the payment token ID submitted by the form:
    token = params[:stripeToken]
    product = Product.first

    # Fixing price
    price_cents = dollars_to_cents(product.price.to_s)
    puts "PRICE #{price_cents}".red

    begin
      charge = Stripe::Charge.create(
      {
        amount: price_cents,
        currency: "usd",
        description: "#{product.name}",
        source: token,
      }
      )
    rescue Stripe::InvalidRequestError => e
      puts "ERROR #{e.message}".red
    end

    if charge
      puts "CHARGE #{charge}".red
      redirect_to cart_path(stripe_receipt: charge.receipt_url)
    else
    end

  end

  def dollars_to_cents(dollars)
    (100 * dollars.to_r).to_i
  end

  def payment
  end
end
