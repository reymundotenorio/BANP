module ApplicationHelper
  # Clean phone number
  def clean_phone(phone)
    phone.remove("(",")"," ", "-") if phone
  end
  # End Clean phone number

  # Format datetime
  def format_datetime(datetime)
    I18n.l(datetime) if datetime
  end
  # End Format datetime

  # Clean history information
  def clean_history(info, attribute)
    # Enabled or Confirmed
    if info == true
      if attribute == "state"
        t("views.show.enabled")

      elsif attribute == "confirmed"
        t("views.show.confirmed")
      end

      # Disabled or Not confirmed
    elsif info == false
      if attribute  == "state"
        t("views.show.disabled")

      elsif attribute == "confirmed"
        t("views.show.not_confirmed")
      end

      # If attribute is datetime
    elsif attribute == "current_sign_in_at" || attribute == "last_sign_in_at"
      format_datetime(info)

    else
      info
    end
  end
  # End Clean history information
end
