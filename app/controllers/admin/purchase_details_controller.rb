class Admin::PurchaseDetailsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find providers with Friendly_ID
  # before_action :set_provider, only: [:show, :history]
  # End Find providers with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  def show
    @details = PurchaseDetail.search(params[:id], params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @details.count

    @purchase_id = params[:id]

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchase-details-#{file_time}"
    template = "admin/purchase_details/show_pdf.html.haml"
    title_pdf = "#{t('purchase.order_details')} ##{@purchase_id}"
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, @details, I18n.l(datetime), title_pdf)
      end
    end
  end
end
