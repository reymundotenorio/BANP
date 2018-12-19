class ApplicationController < ActionController::Base
  # Twilio gem
  require "twilio-ruby"

  # Always run set_lang
  before_action :set_lang
  # End Always run set_lang

  # Domain global variable
  $max_failed_attempts = 4
  Rails.env.development? ? $banp_domain = "http://localhost:3000/" : $banp_domain = "http://www.betterandnice.com/"
  # End Domain global variable

  ### Authentication methods

  #Helper for the view
  helper_method :current_employee, :current_customer

  # Current employee
  def current_employee
    @current_employee ||= Employee.find(session[:employee_id]) if session[:employee_id]
  end

  # Current customer
  def current_customer
    @current_customer ||= Customer.find(session[:customer_id]) if session[:customer_id]
  end

  # Require employee
  def require_employee
    if session[:employee_id] && session[:session_confirmed] == false
      redirect_to admin_two_factor_path, alert: t("views.authentication.otp_required")

    elsif session[:employee_id] == nil && session[:session_confirmed] == nil
      redirect_to admin_sign_in_path, alert: t("views.authentication.sign_in_required") unless current_employee
    end
  end

  # Verify employee state
  def employee_enabled?
    if @employee.state
      return true

    else
      redirect_to admin_auth_notifications_path(found: false), alert: t("views.authentication.account_disabled", email: @employee.email)
      return false
    end
  end

  # Verify customer state
  def customer_enabled?
    if @customer.state
      return true

    else
      redirect_to auth_notifications_path(found: false), alert: t("views.authentication.account_disabled", email: @customer.email)
      return false
    end
  end

  # Verify if user is employee
  def user_is_employee?
    if @user.employee.present?
      @employee = @user.employee
      return true

    else
      redirect_to admin_auth_notifications_path(found: false), alert: t("views.authentication.user_must_be_employee")
      return false
    end
  end

  # Verify if user is customer
  def user_is_customer?
    if @user.customer.present?
      @customer = @user.customer
      return true

    else
      redirect_to auth_notifications_path(found: false), alert: t("views.authentication.user)views.authentication.user_must_be_customer")
      return false
    end
  end

  # Verify user confirmation
  def user_confirmed?(redirect_resend = true)
    if @user.confirmed
      return true

    else
      redirect_to admin_confirm_account_path(email: @user.email), alert: t("views.authentication.account_not_confirmed_resend", email: @user.email) if redirect_resend
      return false
    end
  end

  # Verify user block status
  def user_locked?(redirect_resend = true)
    if @user.failed_attempts >= $max_failed_attempts
      redirect_to admin_unlock_account_path(email: @user.email), alert: t("views.authentication.account_locked_resend", email: @user.email) if redirect_resend
      return true

    else
      return false
    end
  end

  ### End Authentication methods

  # Cookie set language
  def set_lang
    if cookies[:banp_lang] && I18n.available_locales.include?(cookies[:banp_lang].to_sym)
      current_lang = cookies[:banp_lang].to_sym

    else
      current_lang = I18n.default_locale
      cookies.permanent[:banp_lang] = current_lang
    end

    I18n.locale = current_lang
  end
  # End Cookie set language

  # Twilio send SMS
  def send_sms(phone_number, message)
    twilio = Twilio::REST::Client.new
    twilio.messages.create({from: ENV["twilio_phone_number"], to: phone_number, body: message})
  end

  # Redirect to back
  def redirect_to_back(state, path, resource, type)
    if state
      if type == "success"
        redirect_back fallback_location: path, notice: t("alerts.enabled", model: t("activerecord.models.#{resource}"))

      elsif type == "error"
        redirect_back fallback_location: path, alert: t("alerts.not_enabled", model: t("activerecord.models.#{resource}"))
      end

    else
      if type == "success"
        redirect_back fallback_location: path, notice: t("alerts.disabled", model: t("activerecord.models.#{resource}"))

      elsif type == "error"
        redirect_back fallback_location: path, alert: t("alerts.not_disabled", model: t("activerecord.models.#{resource}"))
      end
    end
  end

  # Render PDF
  def to_pdf(name_pdf, template, resource, datetime, pdf_title)
    render pdf: name_pdf,
    template: template,
    layout: "admin/application_pdf.html.haml",
    page_size: "letter",
    # orientation: "Landscape", # Portrait
    margin: { top: 10, bottom: 15 },
    footer: { content: render_to_string("layouts/admin/footer_pdf.html.haml", layout: nil, locals: { datetime: datetime }) },
    locals: { resource: resource, pdf_title: pdf_title }
  end
end
