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

      elsif attribute == "two_factor_auth"
        t("views.show.enabled")

      else
        true
      end

      # Disabled or Not confirmed
    elsif info == false
      if attribute  == "state"
        t("views.show.disabled")

      elsif attribute == "confirmed"
        t("views.show.not_confirmed")

      elsif attribute == "two_factor_auth"
        t("views.show.disabled")

      else
        false
      end

      # If attribute is datetime
    elsif attribute == "current_sign_in_at" || attribute == "last_sign_in_at" || attribute == "purchase_datetime"
      format_datetime(info)

    elsif attribute == "discount"
      "#{info / 100}%"

    elsif attribute == "provider_id"
      Provider.find(info).name

    elsif attribute == "product_id"
      I18n.locale == :es ? Product.find(info).name_spanish : Product.find(info).name

    elsif attribute == "category_id"
      I18n.locale == :es ? Category.find(info).name_spanish : Category.find(info).name

    elsif attribute == "price"
      number_to_currency(info, precision: 2, unit: "$", format: "%u%n", separator: ".", delimiter: ",")

    elsif attribute == "status"
      if info == "ordered"
        I18n.locale == :es ? "Ordenado" : "Ordered"

      elsif info == "received"
        I18n.locale == :es ? "Recibido" : "Received"

      elsif info == "returned"
        I18n.locale == :es ? "Devuelto" : "Returned"

      else
        #code
      end

    else
      info
    end
  end
  # End Clean history information
end
