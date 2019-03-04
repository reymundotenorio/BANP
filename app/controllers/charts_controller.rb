class ChartsController < ApplicationController

  # /charts/sales-by-month
  def sales_by_month
    render json: Sale.enabled.joins(:sale_details).where("( sales.sale_datetime BETWEEN NOW() - INTERVAL 12 MONTH AND NOW() ) AND (sales.paid = true) AND (sale_details.status != 'pending' OR sale_details.status != 'returned')").group_by_month(:sale_datetime).order(:sale_datetime).pluck("DATE_FORMAT(sale_datetime, '%m/%Y') as 'Sale_Date', ( SUM(price * quantity) - (SUM(price * quantity) * (discount / 100)) ) as 'Total'")
  end

  # /charts/purchases-by-month
  def purchases_by_month
    render json: Purchase.enabled.joins(:purchase_details).where("( purchases.purchase_datetime BETWEEN NOW() - INTERVAL 12 MONTH AND NOW() ) AND (purchase_details.status != 'returned')").group_by_month(:purchase_datetime).order(:purchase_datetime).pluck("DATE_FORMAT(purchase_datetime, '%m/%Y') as 'Purchase_Date', ( SUM(price * quantity) - (SUM(price * quantity) * (discount / 100)) ) as 'Total'") ## Fix status == received
  end

  # /charts/sales-by-products
  def sales_by_products
    product_name =   I18n.locale == :es ? "products.name_spanish" : "products.name"

    render json: SaleDetail.not_returned.joins(:product).where("products.state = true").joins(:purchase).where("sales.state = true").group(product_name).order('( SUM(purchase_details.price * quantity) - (SUM(purchase_details.price * quantity) * (discount / 100)) ) DESC').limit(10).pluck("#{product_name}, ( SUM(purchase_details.price * quantity) - (SUM(purchase_details.price * quantity) * (discount / 100)) ) as 'Total'")
  end

  # /charts/purchases-by-products
  def purchases_by_products
    product_name =   I18n.locale == :es ? "products.name_spanish" : "products.name"

    render json: PurchaseDetail.not_returned.joins(:product).where("products.state = true").joins(:purchase).where("purchases.state = true").group(product_name).order('( SUM(purchase_details.price * quantity) - (SUM(purchase_details.price * quantity) * (discount / 100)) ) DESC').limit(10).pluck("#{product_name}, ( SUM(purchase_details.price * quantity) - (SUM(purchase_details.price * quantity) * (discount / 100)) ) as 'Total'")
  end

  # /charts/purchases-by-categories
  def purchases_by_categories
    category_name = I18n.locale == :es ? "categories.name_spanish" : "categories.name"

    render json: PurchaseDetail.not_returned.joins(:product).where("products.state = true").joins(:purchase).where("purchases.state = true").joins("LEFT JOIN categories ON products.category_id = categories.id").where("categories.state = true").group(category_name).order('( SUM(purchase_details.price * quantity) - (SUM(purchase_details.price * quantity) * (discount / 100)) ) DESC').limit(10).pluck("#{category_name}, ( SUM(purchase_details.price * quantity) - (SUM(purchase_details.price * quantity) * (discount / 100)) ) as 'Total'")
  end

  # /charts/purchases-by-providers
  def purchases_by_providers
    provider_name = "providers.name"

    render json: Purchase.enabled.joins(:provider).enabled.joins(:purchase_details).group(provider_name).order('( SUM(price * quantity) - (SUM(price * quantity) * (discount / 100)) ) DESC').limit(10).pluck("#{provider_name}, ( SUM(price * quantity) - (SUM(price * quantity) * (discount / 100)) ) as 'Total'")
  end

  # /charts/purchases-by-employees
  def purchases_by_employees
    employee_name = "CONCAT_WS(' ', employees.first_name, employees.last_name)"

    render json: Purchase.enabled.joins(:employee).enabled.joins(:purchase_details).group(employee_name).order('( SUM(price * quantity) - (SUM(price * quantity) * (discount / 100)) ) DESC').limit(10).pluck("#{employee_name}, ( SUM(price * quantity) - (SUM(price * quantity) * (discount / 100)) ) as 'Total'")
  end



  # /charts/products-by-categories
  def products_by_categories
    category_name = I18n.locale == :es ? "categories.name_spanish" : "categories.name"

    render json: Product.joins(:category).group(category_name).order("COUNT(categories.id) DESC").count
    # render json: Product.group(:name).count
  end
end
