class Admin::Authentication::NotificationsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # admin/authentication/notifications
  def index
    @source = params[:source]
    @source = "not-found" unless @source
  end
end
