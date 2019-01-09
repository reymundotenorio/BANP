class CartController < ApplicationController
  require "paypal-sdk-rest"
  include PayPal::SDK::OpenIDConnect
  include PayPal::SDK::REST

  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Authentication
  before_action :require_customer
  # End Authentication

  def index
  end

  def show
    # Generate URL to Get Authorize code
    # @token = Tokeninfo.authorize_url(scopes: "openid profile")

    # # Get token information with the authorize code
    # tokeninfo = Tokeninfo.create("")
    # puts "TOKEN INFO: #{tokeninfo.to_hash}"

    # # Refresh tokeninfo object
    # tokeninfo = tokeninfo.refresh
    # puts "TOKEN INFO ON REFRESH: #{tokeninfo.to_hash}"

    # # Create tokeninfo by using refresh token
    # tokeninfo = Tokeninfo.refresh("")
    # puts "TOKEN INFO WITH REFRESH TOKEN: #{tokeninfo.to_hash}"

    # # Get Userinfo
    # userinfo = tokeninfo.userinfo
    # puts "USER INFO: #{userinfo.to_hash}"

    # # Get logout url
    # puts tokeninfo.logout_url.red

    # # Build Payment object
    # @payment = Payment.new({
    #   :intent =>  "sale",
    #   :payer =>  {
    #     :payment_method =>  "paypal" },
    #     :redirect_urls => {
    #       :return_url => "http://localhost:3000/payment/execute",
    #       :cancel_url => "http://localhost:3000/" },
    #       :transactions =>  [{
    #         :item_list => {
    #           :items => [{
    #             :name => "Testing",
    #             :sku => "123456789A",
    #             :price => "5",
    #             :currency => "USD",
    #             :quantity => 1 }]},
    #             :amount =>  {
    #               :total =>  "5",
    #               :currency =>  "USD" },
    #               :description =>  "This is the payment transaction description." }]})
    #
    # if @payment.create
    #   @payment.id     # Payment Id
    # else
    #   @payment.error  # Error Hash
    # end

    # payment = Payment.find("PAY-3Y6463124N7564924LQZWDAI")
    #
    # if payment.execute( :payer_id => "DUFRQ8GWYMJXC" )
    #   # Success Message
    #   # Note that you'll need to `Payment.find` the payment again to access user info like shipping address
    # else
    #   payment.error # Error Hash
    # end

  end

  def test
    params[:products].each do |id, attributes|
      # if family = Family.find_by_id(id)
      #   family.update_attributes(attributes)
      #   @families << family

      puts "TEST: #{id} - #{attributes}"
    end
  end
end
