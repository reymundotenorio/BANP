class Admin::DashboardController < ApplicationController
  def index
    @product_count = Product.group_by_day(:created_at).count
  end
end
