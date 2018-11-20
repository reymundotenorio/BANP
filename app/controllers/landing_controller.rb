class LandingController < ApplicationController
  # Landing layout
  layout "application_landing"
  # End Landing layout

  def index
  @categories = Category.all
  end
end
