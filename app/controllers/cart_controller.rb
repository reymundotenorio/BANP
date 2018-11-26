class CartController < ApplicationController
  # Sync model DSL
  enable_sync only: [:create]
  # End Sync model DSL

  def create
    @cart = Cart.new(cart_params)
    @cart.save
  end

  private

  # Cart params
  def cart_params
    params.require(:cart).permit(:costumer_id)
  end
end
