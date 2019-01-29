class CartController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Authentication
  before_action :require_customer
  # End Authentication

  def index
    # token = params[:token]
    #
    # # If token param is present
    # if token
    #   flash.now[:alert] = token
    #   render :index
    # end
  end
end
