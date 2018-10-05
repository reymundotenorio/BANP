class Admin::Authentication::NotificationsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /authentication/notifications
  def index
    @found = params[:found]

    if @found
    else
      @found = true
    end
  end
end
