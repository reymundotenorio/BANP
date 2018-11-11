module ApplicationHelper
  # Clean phone number
  def clean_phone(phone)
    phone.remove("(",")"," ", "-")
  end
  # End Clean phone number
  
  # Format datetime
  def format_datetime(datetime)
    I18n.l(datetime)
  end
  # End Format datetime

  # Clean history information
  def clean_history(info, confirmed = false)
    if info == true
      if confirmed
        t("views.show.confirmed")
      else
        t("views.show.enabled")
      end

    elsif info == false
      if confirmed
        t("views.show.not_confirmed")
      else
        t("views.show.disabled")
      end

    else
      info
    end
  end
  # End Clean history information

  # Reset active paths
  def reset_active_paths
    $provider_path = false
    $category_path = false
  end
end
