class ProductsController < ApplicationController
  # Landing layout
  layout "application_ecommerce"
  # End Landing layout

  def index
    @categories = Category.all
    @category_filter = params[:category]

    @category_filter = @category_filter.blank? ? "" : @category_filter.strip.downcase
  end
end
