class ProductsController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Find products with Friendly_ID
  before_action :set_product, only: [:show]
  # End Find products with Friendly_ID

  def index
    @categories = Category.enabled
    @category_filter = params[:category]
    @product_filter = params[:product]

    @category_filter = @category_filter.blank? ? "" : @category_filter.strip.downcase
    @product_filter = @product_filter.blank? ? "" : @product_filter.strip

    # If product filter is empty
    if @product_filter == ""
      # And if category filter is empty
      if @category_filter == ""
        @products = Product.enabled.paginate(page: params[:page], per_page: 6) # Products with pagination

        # if category filter is not empty
      else
        @products = Product.enabled.find_category(@category_filter).paginate(page: params[:page], per_page: 6) # Products with pagination
        @category = Category.friendly.find(@category_filter)
      end

      # If product filter not is empty
    else
      @products = Product.search(@product_filter, "enabled-only").paginate(page: params[:page], per_page: 6) # Products with pagination
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def show
    @category = @product.category
    @products = Product.enabled.find_category(@category.slug.strip.downcase).reject{ |p| p.id == @product.id}
    @products_first = @products.first
    @products = @products.reject{ |p| p.id == @products_first.id}
  end


  private

  # Set Product
  def set_product
    @product = Product.friendly.find(params[:id])

  rescue
    redirect_to products_path, alert: t("alerts.not_found", model: t("activerecord.models.product"))
  end
end
