class ApplicationController < ActionController::Base
  # Always run set_lang
  before_action :set_lang
  # End Always run set_lang

  # Domain global variable
  if Rails.env == "development"
    $banp_domain = 'http://localhost:3000/'
  else
    $banp_domain = 'http://www.betterandnice.com/'
  end
  # End Domain global variable

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
end
