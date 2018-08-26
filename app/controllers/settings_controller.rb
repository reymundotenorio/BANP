class SettingsController < ApplicationController

  # Change current language
  def change_lang
    current_lang = params[:lang].to_s.strip.to_sym
    current_lang = I18n.default_locale unless I18n.available_locales.include?(current_lang)
    cookies.permanent[:banp_lang] = current_lang
    redirect_to request.referer || root_url
  end
  # End Change current language

end
