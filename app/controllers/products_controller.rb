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
      @products = Product.enabled.paginate(page: params[:page], per_page: 6) # Products with pagination

    else
      @products = Product.enabled.find_category(@category_filter).paginate(page: params[:page], per_page: 6) # Products with pagination
    end

    respond_to do |format|
      format.html
      format.js
    end
  end
end
