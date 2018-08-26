class HomeController < ApplicationController
  # Admin layout
  layout 'admin/application'
  # End Admin layout

  def index
    # render_404
  end

  def render_404
    render file: "#{Rails.root}/public/404", status: :not_found
  end
end
