class ChartsController < ApplicationController

  def product_by_categories
    category_name = I18n.locale == :es ? "categories.name_spanish" : "categories.name"

    render json: Product.joins(:category).group(category_name).count
    # render json: Product.group(:name).count
  end

  def purchases_by_providers
    provider_name = "providers.name"

    render json: Purchase.enabled.joins(:provider).enabled.joins(:purchase_details).group(provider_name).order('SUM(price * quantity) DESC').limit(10).sum("price * quantity")
  end

  def purchases_by_employees
    employee_name = "CONCAT_WS(' ', employees.first_name, employees.last_name)"

    render json: Purchase.enabled.joins(:employee).enabled.joins(:purchase_details).group(employee_name).order('SUM(price * quantity) DESC').limit(10).sum("price * quantity")
  end

  def purchases_by_products
    product_name =   I18n.locale == :es ? "products.name_spanish" : "products.name"

    render json: PurchaseDetail.joins(:product).where("products.state = true").group(product_name).order('SUM(purchase_details.price * quantity) DESC').limit(10).sum("purchase_details.price * quantity")
  end

  def purchases_by_categories
    category_name = I18n.locale == :es ? "categories.name_spanish" : "categories.name"

    render json: PurchaseDetail.joins(:product).where("products.state = true").joins("LEFT JOIN categories ON products.category_id = categories.id").where("categories.state = true").group(category_name).order('SUM(purchase_details.price * quantity) DESC').limit(10).sum("purchase_details.price * quantity")
  end
end
