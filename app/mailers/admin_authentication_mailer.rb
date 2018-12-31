class AdminAuthenticationMailer < ApplicationMailer
  # Mailer layout
  layout "mailer"
  default template_path: "admin/authentication/mailer"
  # End Mailer layout

  def confirmation_instructions(user, token, locale, ip, location)
    @user = user
    @employee = user.employee
    @token = token
    @ip = ip
    @location = location

    I18n.with_locale(locale) do
      mail(to: @user.email, subject: "BANP - #{I18n.t('views.mailer.confirm_account')}")
    end
  end

  def unlock_instructions(user, token, locale, ip, location)
    @user = user
    @employee = user.employee
    @token = token
    @ip = ip
    @location = location

    I18n.with_locale(locale) do
      mail(to: @user.email, subject: "BANP - #{I18n.t('views.mailer.unlock_account')}")
    end
  end

  def reset_password_instructions(user, token, locale, ip, location)
    @user = user
    @employee = user.employee
    @token = token
    @ip = ip
    @location = location

    I18n.with_locale(locale) do
      mail(to: @user.email, subject: "BANP - #{I18n.t('views.mailer.reset_password')}")
    end
  end

  def update_password(user, locale, ip, location)
    @user = user
    @employee = user.employee
    @ip = ip
    @location = location

    I18n.with_locale(locale) do
      mail(to: @user.email, subject: "BANP - #{I18n.t('views.mailer.update_password')}")
    end
  end
end
