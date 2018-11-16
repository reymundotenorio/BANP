class Admin::ProductsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find products with Friendly_ID
  before_action :set_product, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find products with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # /products
  def index
    @products = Product.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Products with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "products-#{file_time}"
    template = "admin/products/index_pdf.html.haml"
    title_pdf = t("header.navigation.products")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Product.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # /product/new
  def new
    @product = Product.new

    @search_form_path = admin_new_product_path(@product)
    @categories = Category.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 5) # Categories with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # /product/:id
  def show
    # Product found by before_action

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "product-#{@product.slug}-#{file_time}"
    template = "admin/products/show_pdf.html.haml"
    title_pdf = t("activerecord.models.product")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @product, I18n.l(datetime), title_pdf)
      end
    end
  end

  # /product/:id/edit
  def edit
    # Product found by before_action

    @search_form_path = admin_edit_product_path(@product)
    @categories = Category.search(params[:search], "enabled-only").paginate(page: params[:page], per_page: 5) # Categories with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # /product/:id/history
  def history
    # Product found by before_action

    @history = @product.audits
  end

  # Create
  def create
    @product = Product.new(product_params)

    # Deleting blank spaces
    @product[:name] = @product[:name].strip
    @product[:name_spanish]= @product[:name_spanish].strip
    # @product[:price] = @product[:price].strip
    @product[:content] = @product[:content].strip
    @product[:content_spanish] = @product[:content_spanish].strip
    @product[:description] = @product[:description].strip
    @product[:description_spanish] = @product[:description_spanish].strip
    @product[:recipes] = @product[:recipes].strip
    @product[:recipes_spanish] = @product[:recipes_spanish].strip
    # End Deleting blank spaces

    # If record was saved
    if @product.save
      redirect_to [:admin, @product], notice: t("alerts.created", model: t("activerecord.models.product"))

      # If record was not saved
    else
      render :new
    end
  end

  # Update
  def update
    if @product.update(product_params)
      redirect_to [:admin, @product], notice: t("alerts.updated", model: t("activerecord.models.product"))

    else
      render :edit
    end
  end

  # Active
  def active
    if @product.update(state: true)
      redirect_to_back(true, admin_products_path, "product", "success")

    else
      redirect_to_back(true, admin_products_path, "product", "error")
    end
  end

  # Deactive
  def deactive
    if @product.update(state: false)
      redirect_to_back(false, admin_products_path, "product", "success")

    else
      redirect_to_back(false, admin_products_path, "product", "error")
    end
  end

  private

  # Set Product
  def set_product
    @product = Product.friendly.find(params[:id])

  rescue
    redirect_to admin_products_path, alert: t("alerts.not_found", model: t("activerecord.models.product"))
  end

  # Product params
  def product_params
    params.require(:product).permit(:name, :name_spanish, :price, :content, :content_spanish, :description, :description_spanish, :recipes, :recipes_spanish, :image, :category_id)
  end
end
