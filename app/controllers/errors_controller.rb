class ErrorsController < ApplicationController
  # Authentication layout
  layout "admin/authentication"
  # End Authentication layout

  # /404
  def not_found
    render status: 404
  end

  # /500
  def internal_server_error
    render status: 500
  end
end
