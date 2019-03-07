class Admin::DashboardController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  before_action :require_employee
  # End Authentication

  def index
  end
end
