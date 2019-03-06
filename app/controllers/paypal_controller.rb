class PaypalController < ApplicationController
  require "paypal-sdk-rest"
  include PayPal::SDK::OpenIDConnect
  include PayPal::SDK::REST

  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Authentication
  before_action :require_customer
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
    address = params[:address] || current_customer.address

    # If code param is present
    if code
      # Get token information with the authorize code
      begin
        tokeninfo = Tokeninfo.create(code) if code

      rescue PayPal::SDK::Core::Exceptions::BadRequest => e # Token not found or expired
        flash.now[:alert] = e.message
        paypal_auth
        return
      end
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

      # Calculations
      items_subtotal = product_items.inject(0) {|sum, hash| sum + ((hash[:price]).to_f * (hash[:quantity]).to_i)}
      items_subtotal = items_subtotal.round(2)

      # zip_code = current_customer.zipcode
      # zip_info = ZipCodes.identify(zip_code)


      # items_shipping = items_subtotal * 0.05
      # items_shipping = items_shipping.round(2)
      #
      # items_discount = (items_shipping * 0.10) * -1
      # items_discount = items_discount.round(2)
      #
      # items_total = items_subtotal + items_shipping + items_discount
      # items_total = items_total.round(2)

      # puts "Subtotal: #{items_subtotal}"
      # puts "Zip code: #{zip_info}"

      # Creating the order
      sale_order = ::Sale.new

      sale_order.sale_datetime = Time.current
      sale_order.status = "pending"
      sale_order.delivery_status = "in_queue"
      sale_order.discount = 0.00
      sale_order.customer_id = current_customer.id
      sale_order.employee_id = 1 # SIBANP
      sale_order.observations = address

      sale_order.payment_method = "Paypal"
      sale_order.payment_reference = "-"
      sale_order.paid = false

      # Iterating products
      params[:products].each do |id, attributes|
        cart_product = Product.find(attributes["id"].to_i)

        if cart_product
          sale_order.sale_details.build(product_id: cart_product.id, price: cart_product.price, quantity: attributes["quantity"].to_i, status: "ordered")
        end
      end
      # End Iterating products

      # If order was saved correcty
      if sale_order.save
        sync_new sale_order

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
                items: product_items
                # ,
                # shipping_address: {
                #   recipient_name: "#{current_customer.first_name} #{current_customer.last_name}",
                #   line1: address, #current_customer.address,
                #   phone: current_customer.phone#,
                #   city: zip_info[:city],
                #   state: zip_info[:state_code],
                #   postal_code: zip_code,
                #   country_code: "US"
                # }
              }
            }
          ],
          note_to_payer: I18n.t("views.cart.paypal_note_payer"),
          redirect_urls: {
            return_url: paypal_payment_url(order: sale_order.id),
            cancel_url: cart_url
          }
        }
        )  # Creating the order

        # If the payment was correctly created
        if payment.create
          # payment.id
          redirect_to payment.links.find{|v| v.rel == "approval_url" }.href

          # If the payment was not correctly created
        else
          puts payment.error # Error Hash
          redirect_to cart_path, alert: "#{t('views.cart.problem_payment_creating')}"
          return
        end

        # If order was not saved correcty
      else
        errors_messages = ""

        sale_order.errors.full_messages.each do |error|
          errors_messages += " #{error}."
        end

        errors_messages = errors_messages.strip

        redirect_to cart_path, alert: errors_messages
        return
      end
      # End Creating the order

      # If code param is not present
    else
      redirect_to cart_path, alert: t("views.cart.param_code_incorrect")
      return
    end
  end

  def paypal_payment

    order_id = params[:order]

    payment_id = params[:paymentId]
    # token = params[:token]
    payer_id = params[:PayerID]

    # If Payment ID and Payer ID are present
    if payment_id && payer_id
      payment = Payment.find(payment_id)

      # If payment was executed correctly
      if payment.execute(payer_id: payer_id)

        # Creating the order
        sale_order = ::Sale.find(order_id)

        sale_order.status = "ordered"
        sale_order.payment_reference = payment_id
        sale_order.paid = true

        if sale_order.save
          sync_update sale_order
          # redirect_to cart_path, notice: t("views.cart.payment_correctly")

          redirect_to tracking_path(sale_order.id, clean_cart: "clean-all"), notice: t("views.cart.payment_correctly")
          return

        else
          redirect_to cart_path, error: t("sale.problem_generating_order")
          return
        end
        # End Creating the order

        # Decrease inventory
        # Save sale / transaction
        # Trigger notification to admin / saler
        # Add sale to delivery queue
        # Show PDF invoice (new tab) and redirect to delivery tracking

        # If payment was not executed correctly
      else
        puts payment.error # Error Hash
        redirect_to cart_path, alert: "#{t('views.cart.problem_payment_executing')}"
        return
      end

      # If Payment ID and Payer ID are not present
    else
      redirect_to cart_path, alert: t("views.cart.param_payer_payment_incorrect")
      return
    end
  end

  def paypal_auth
    # Generate URL to Get Authorize code
    auth_url = Tokeninfo.authorize_url() # scopes: "openid profile"
    redirect_to auth_url
  end
end
