class ChartsController < ApplicationController

  def product_by_category
    I18n.locale == :es ? category_name = "categories.name_spanish" : category_name = "categories.name"

    render json: Product.joins(:category).group(category_name).count
    # render json: Product.group(:name).count
  end

  def purchases_by_provider
    provider_name = "providers.name"
    render json: Purchase.left_joins(:provider).group(provider_name).order("COUNT(#{provider_name}) DESC").limit(10).count
  end

end
