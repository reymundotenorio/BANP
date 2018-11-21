class ProductsController < ApplicationController
  # Landing layout
  layout "application_ecommerce"
  # End Landing layout

  def index
    @categories = Category.enabled
    @category_filter = params[:category]

    @category_filter = @category_filter.blank? ? "" : @category_filter.strip.downcase

    # @products = Product.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 15) # Products with pagination
    if @category_filter == ""
      @products = Product.enabled
      
    else
      @products = Product.enabled.find_category(@category_filter)
    end
  end
end
