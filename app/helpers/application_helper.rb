module ApplicationHelper
  # Clean phone number
  def clean_phone(phone)
    phone.remove("(",")"," ", "-")
  end
  # End Clean phone number

  # Clean history information
  def clean_history(info)
    if info==true
      t('views.show.enabled')

    elsif info==false
      t('views.show.disabled')
      
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
