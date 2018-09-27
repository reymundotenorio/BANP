class AuthenticationMailer < ApplicationMailer
  # Mailer layout
  layout "mailer"
  # End Mailer layout

  # Default options
  default from: "betterandniceproduce@gmail.com"
  default template_path: "admin/authentication/mailer"
  # End Default options

  def confirmation_instructions(user, token, locale)
    @user = user
    @token = token

    I18n.with_locale(locale) do
      mail(to: @user.email, subject: "BANP - #{I18n.t('views.mailer.confirm_account')}")
    end
  end

  def unlock_instructions(user, token, locale)
    @user = user
    @token = token

    I18n.with_locale(locale) do
      mail(to: @user.email, subject: "BANP - #{I18n.t('views.mailer.unlock_account')}")
    end
  end

  def reset_password_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.email, subject: "Instrucciones para reestablecer contraseña")
  end
end
