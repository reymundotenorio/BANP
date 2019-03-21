class Admin::NotificationsController < ApplicationController
  # Find notifications
  before_action :set_notification, only: [:notification_redirect]
  # End Find notifications

  # Authentication
  before_action :require_employee, :require_seller_driver
  # End Authentication

  # admin/notification/:id
  def notification_redirect
    @notification.read_by = "true"
    # @notification.read_by = @notification.read_by == "" ? current_customer.id : ", #{current_customer.id}"

    if @notification.save
      puts "Notification saved"

    else
      puts "Notification not saved"
    end

    redirect_to @notification.path
  end

  # admin/notifications/clean
  def clean_notifications
    redirect_url = params[:redirect_to] || admin_root_path

    @notifications = Notification.unread

    if @notifications
      @notifications.each do |notification|
        notification.read_by = "true"

        if notification.save
          puts "Notification cleaned"

        else
          puts "Notification not cleaned"
        end
      end

      redirect_to redirect_url
    end
  end

  private

  # Set Notification
  def set_notification
    @notification = Notification.find(params[:id])

  rescue
    redirect_to admin_root_path, alert: t("alerts.not_found", model: t("activerecord.models.notification"))
  end
end
