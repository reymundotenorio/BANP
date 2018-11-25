class ProductsController < ApplicationController
  # Landing layout
  layout "application_ecommerce"
  # End Landing layout

  # Find products with Friendly_ID
  before_action :set_product, only: [:show]
  # End Find products with Friendly_ID

  def index
    @categories = Category.enabled
    @category_filter = params[:category]

    @category_filter = @category_filter.blank? ? "" : @category_filter.strip.downcase


    # @products = Product.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 15) # Products with pagination
    if @category_filter == ""
      @products = Product.enabled.paginate(page: params[:page], per_page: 6) # Products with pagination

    else
      @products = Product.enabled.find_category(@category_filter).paginate(page: params[:page], per_page: 6) # Products with pagination
      @category = Category.friendly.find(@category_filter)
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
