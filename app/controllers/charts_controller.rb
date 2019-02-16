class ChartsController < ApplicationController

  def product_by_category
    I18n.locale == :es ? category_name = "categories.name_spanish" : category_name = "categories.name"

    render json: Product.joins(:category).group(category_name).count
    # render json: Product.group(:name).count
  end

  def purchases_by_provider
    provider_name = "providers.name"
    # render json: PurchaseDetail.joins(:purchase).sum("price * quantity")
    # render json: Purchase.joins(:provider).group(provider_name).order("COUNT(#{provider_name}) DESC").limit(10).count

    # render json: Purchase.joins(:provider).joins(:purchase_details).group(provider_name).sum("price * quantity")

    # render json: Purchase.joins(:provider).joins(:purchase_details).group(provider_name).select("#{provider_name}, SUM(price * quantity) as Total").order("Total DESC")

    render json: Purchase.enabled.joins(:provider).joins(:purchase_details).group(provider_name).order('SUM(price * quantity) DESC').limit(10).sum("price * quantity")
  end
end
