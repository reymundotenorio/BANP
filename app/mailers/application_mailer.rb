class ApplicationMailer < ActionMailer::Base
  # Default options
  default from: "info@betterandnice.com"
  default template_path: "admin/authentication/mailer"
  # End Default options
end
