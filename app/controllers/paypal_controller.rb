class PaypalController < ApplicationController
  require "paypal-sdk-rest"
  include PayPal::SDK::OpenIDConnect
  include PayPal::SDK::REST

  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Authentication
  # before_action :require_customer
  # End Authentication

  def paypal_sign_in
    code = params[:code]
    redirect_to paypal_order_path(code: code)
    return
  end

  def paypal_order
  end

  def paypal_checkout
    code = params[:code]

    # If code param is present
    if code
      # Get token information with the authorize code
      begin
        tokeninfo = Tokeninfo.create(code) if code

      rescue PayPal::SDK::Core::Exceptions::BadRequest => e # Token not found or expired
        paypal_auth
        return
      end

      puts "****************************************".red
      puts "PASO #1".red
      puts "****************************************".red
      # puts tokeninfo.to_hash

      # Refresh tokeninfo object
      # tokeninfo = tokeninfo.refresh
      # puts tokeninfo.to_hash

      # Create tokeninfo by using refresh token
      # tokeninfo = Tokeninfo.refresh(tokeninfo.refresh_token)
      # puts tokeninfo.to_hash

      # Get Userinfo
      # userinfo = tokeninfo.userinfo
      # puts userinfo.to_hash

      # Get logout url
      # puts tokeninfo.logout_url

      product_items = Array.new

      puts "****************************************".red
      puts "PASO #2".red
      puts "****************************************".red

      params[:products].each do |id, attributes|
        product = Product.find(attributes["id"].to_i)

        item =
        {
          name: I18n.locale == :es ? "#{product.name} (#{attributes['quantity']})" : "#{product.name_spanish} (#{attributes['quantity']})",
          description: I18n.locale == :es ? product.description : product.description_spanish,
          sku: product.barcode,
          price: "#{product.price}",
          currency: "USD",
          quantity: attributes["quantity"]
        }

        product_items.push(item)
      end

      puts "****************************************".red
      puts "PASO #3".red
      puts "****************************************".red

      # puts "Product items: #{product_items}".red

      # Calculations
      items_subtotal = product_items.inject(0) {|sum, hash| sum + ((hash[:price]).to_f * (hash[:quantity]).to_i)}
      items_subtotal = items_subtotal.round(2)

      puts "****************************************".red
      puts "PASO #4".red
      puts "****************************************".red

      zip_code = "33151" #@current_customer.zipcode
      zip_info = ZipCodes.identify(zip_code)

      puts "****************************************".red
      puts "PASO #5".red
      puts "****************************************".red

      # items_shipping = items_subtotal * 0.05
      # items_shipping = items_shipping.round(2)
      #
      # items_discount = (items_shipping * 0.10) * -1
      # items_discount = items_discount.round(2)
      #
      # items_total = items_subtotal + items_shipping + items_discount
      # items_total = items_total.round(2)

      # puts "Subtotal: #{items_subtotal}".red
      # puts "Zip code: #{zip_info}".red

      # Build Payment object
      payment = Payment.new(
        {
          intent: "sale",
          payer: {
            payment_method: "paypal"
          },
          transactions: [
            {
              amount: {
                total: "#{items_subtotal}",
                currency: "USD"
                # details: {
                #   subtotal: "#{items_subtotal}",
                #   shipping: "#{items_shipping}",
                #   shipping_discount: "#{items_discount}"
                # }
              },
              description: I18n.t("views.cart.paypal_description"),
              item_list: {
                items: product_items,
                shipping_address: {
                  recipient_name: "#{current_customer.first_name} #{current_customer.last_name}",
                  line1: @current_customer.address,
                  city: zip_info[:city],
                  state: zip_info[:state_code],
                  phone: @current_customer.phone,
                  postal_code: zip_code,
                  country_code: "US"
                }
              }
            }
          ],
          note_to_payer: I18n.t("views.cart.paypal_note_payer"),
          redirect_urls: {
            return_url: paypal_payment_url,
            cancel_url: cart_url
          }
        }
      )

      puts "****************************************".red
      puts "PASO #6".red
      puts "****************************************".red

      # If the payment was correctly created
      if payment.create
        # payment.id
        redirect_to payment.links.find{|v| v.rel == "approval_url" }.href

        puts "****************************************".red
        puts "PASO #7".red
        puts "****************************************".red

        # If the payment was not correctly created
      else
        # payment.error  # Error Hash
        redirect_to cart_path, alert: "Hubo un problema al crear el pago: #{payment.error}"

        puts "****************************************".red
        puts "PASO #8".red
        puts "****************************************".red
        return
      end

      # If code param is not present
    else
      redirect_to cart_path, alert: "Los parametros recibidos (code) son incorrectos, por favor, intente nuevamente ejecutar el pago"

      puts "****************************************".red
      puts "PASO #9".red
      puts "****************************************".red
      return
    end
  end

  def paypal_payment
    payment_id = params[:paymentId]
    # token = params[:token]
    payer_id = params[:PayerID]

    # If Payment ID and Payer ID are present
    if payment_id && payer_id
      payment = Payment.find(payment_id)

      # If payment was executed correctly
      if payment.execute(payer_id: payer_id)
        # Success Message

        # Decrease inventory
        # Save sale / transaction
        # Trigger notification to admin / saler
        # Add sale to delivery queue
        # Show PDF invoice (new tab) and redirect to delivery tracking

        redirect_to root_path(msj: "successful-payment"), notice: "El pago fue ejecutado correctamente"
        return

        # If payment was not executed correctly
      else
        # payment.error # Error Hash
        redirect_to cart_path, alert: "Hubo un problema al ejecutar el pago: #{payment.error}"
        return
      end

      # If Payment ID and Payer ID are not present
    else
      redirect_to cart_path, alert: "Los paramentros recibidos (Paymente ID | Payer ID) son incorrectos, por favor, intente nuevamente ejecutar el pago"
      return
    end
  end

  def paypal_auth
    # Generate URL to Get Authorize code
    auth_url = Tokeninfo.authorize_url() # scopes: "openid profile"
    redirect_to auth_url
  end
end
