class Admin::NotificationsController < ApplicationController
  # Find notifications
  before_action :set_notification, only: [:notification_redirect]
  # End Find notifications

  # Authentication
  before_action :require_employee
  # End Authentication

  def notification_redirect
    @notification.read_by = "true"
    
    if @notification.save
      puts "Notification saved"

    else
      puts "Notification not saved"
    end

    redirect_to @notification.path
  end

  private

  # Set Notification
  def set_notification
    @notification = Notification.find(params[:id])

  rescue
    redirect_to admin_root_path, alert: t("alerts.not_found", model: t("activerecord.models.notification"))
  end
end
