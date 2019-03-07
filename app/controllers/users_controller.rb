class UsersController < ApplicationController
  # Ecommerce layout
  layout "application_ecommerce"
  # End Ecommerce layout

  # Find sale order with Friendly_ID
  before_action :set_customer, only: [:customer_update_password, :customer_change_password]
  # End Find sale order with Friendly_ID

  # Authentication
  before_action :require_customer
  # End Authentication

  # user/update-password
  def customer_update_password
    @user = @customer.user
    @required = false
  end

  # Change customer password
  def customer_change_password
    @user = @customer.user
    update_params = user_params

    if update_params[:two_factor_auth] == "true"
      update_params[:two_factor_auth] = true
    else
      update_params[:two_factor_auth] = false
    end

    if @user.update(update_params)
      redirect_to customer_path, notice: t("views.mailer.password_and_2FA_updated")

    else
      render :customer_update_password
    end
  end

  private

  def set_customer
    @customer = Customer.find(current_customer.id)

  rescue
    redirect_to sign_in_path, alert: t("alerts.not_found", model: t("activerecord.models.user"))
  end

  # User params
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :two_factor_auth)
  end
end
