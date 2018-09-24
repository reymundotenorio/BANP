class UserMailer < ApplicationMailer
  default from: "betterandniceproduce@gmail.com"
  layout "mailer"
  # default template_path: "user_mailer/sample_email"s

  def sample_email
    @user = "Reymundo Tenorio"
    mail(to: "reymundotenorio@gmail.com", subject: "Sample Email")
  end

  def confirmation_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.correo, subject: "Instrucciones de confirmación")
  end

  def reset_password_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.correo, subject: "Instrucciones para reestablecer contraseña")
  end

  def unlock_instructions(user, token)
    @user = user
    @token = token
    mail(to: @user.correo, subject: "Instrucciones de desbloqueo")
  end
end
