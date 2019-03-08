class Admin::CategoriesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find categories with Friendly_ID
  before_action :set_category, only: [:show, :edit, :update, :active, :deactive, :history]
  # End Find categories with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :active, :deactive]
  # End Sync model DSL

  # Authentication
  before_action :require_employee, :require_administrator
  # End Authentication

  # Authentication
  before_action :require_seller_warehouse_supervisor, only: [:index, :show]
  # End Authentication

  # Authentication
  skip_before_action :require_administrator, only: [:index, :show]
  # End Authentication

  # admin/categories
  def index
    @categories = Category.search(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Categories with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @categories.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "categories-#{file_time}"
    template = "admin/categories/index_pdf.html.haml"
    title_pdf = t("header.navigation.categories")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Category.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/category/new
  def new
    @category = Category.new
  end

  # admin/category/:id)
  def show
    # Category found by before_action

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "category-#{@category.slug}-#{file_time}"
    template = "admin/categories/show_pdf.html.haml"
    title_pdf = t("activerecord.models.category")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.pdf do
        to_pdf(name_pdf, template, @category, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/category/:id/edit
  def edit
    # Category found by before_action
  end

  # admin/category/:id/history
  def history
    # Category found by before_action

    @history = @category.audits
  end

  # Create
  def create
    @category = Category.new(category_params)

    # Deleting blank spaces
    @category[:name] = @category[:name].strip
    @category[:name_spanish] = @category[:name_spanish].strip
    @category[:description] = @category[:description].strip
    @category[:description_spanish] = @category[:description_spanish].strip
    # End Deleting blank spaces

    # If record was saved
    if @category.save
      redirect_to [:admin, @category], notice: t("alerts.created", model: t("activerecord.models.category"))

      # If record was not saved
    else
      render :new
    end
  end

  # Update
  def update
    if @category.update(category_params)
      redirect_to [:admin, @category], notice: t("alerts.updated", model: t("activerecord.models.category"))

    else
      render :edit
    end
  end

  # Active
  def active
    if @category.update(state: true)
      redirect_to_back(true, admin_categories_path, "category", "success")

    else
      redirect_to_back(true, admin_categories_path, "category", "error")
    end
  end

  # Deactive
  def deactive
    if @category.update(state: false)
      redirect_to_back(false, admin_categories_path, "category", "success")

    else
      redirect_to_back(false, admin_categories_path, "category", "error")
    end
  end

  private

  # Set Category
  def set_category
    @category = Category.friendly.find(params[:id])

  rescue
    redirect_to admin_categories_path, alert: t("alerts.not_found", model: t("activerecord.models.category"))
  end

  # Category params
  def category_params
    params.require(:category).permit(:name, :name_spanish, :description, :description_spanish, :image)
  end
end
