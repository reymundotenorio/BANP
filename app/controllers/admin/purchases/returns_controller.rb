class Admin::Purchases::ReturnsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Authentication
  # before_action :require_employee
  # End Authentication

  # admin/products
  def index
    @returns = PurchaseDetail.search_returns(params[:search]).paginate(page: params[:page], per_page: 15) # Returns with pagination
    @count = @returns.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "returns-#{file_time}"
    template = "admin/purchases/returns/index_pdf.html.haml"
    title_pdf = t("header.navigation.returns")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, PurchaseDetail.returns, I18n.l(datetime), title_pdf)
      end
    end
  end
end
