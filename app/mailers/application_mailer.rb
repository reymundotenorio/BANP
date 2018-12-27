class ApplicationMailer < ActionMailer::Base
  # Default options
  default from: '"BANP" <info@betterandnice.com>'
  default template_path: "admin/authentication/mailer"
  # End Default options
end
