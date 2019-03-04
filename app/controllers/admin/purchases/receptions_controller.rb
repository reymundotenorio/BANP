class Admin::Purchases::ReceptionsController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find purchase reception with Friendly_ID
  before_action :set_purchase_reception, only: [:new, :show, :edit, :create, :deactive, :history]
  # End Find purchase reception with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # /admin/purchases/receptions
  def index
    @receptions = Purchase.search_reception(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Receptions with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @receptions.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchase-receptions-#{file_time}"
    template = "admin/purchases/receptions/index_pdf.html.haml"
    title_pdf = t("purchase.receptions")
    # End PDF view configuration

    respond_to do |format|
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Purchase.receptions, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/purchases/reception/new
  def new
    @search_form_path = admin_new_purchase_reception_path(@reception)
    @form_url = admin_purchases_reception_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/reception/:id/edit
  def edit
    # Order found by before_action
    @reception.discount = "%.2f" % @reception.discount
    @reception.discount = "0#{@reception.discount.to_s.gsub! '.', ''}" if @reception.discount < 10

    @search_form_path =admin_edit_purchase_reception_path(@reception)
    @form_url = admin_purchases_reception_path
    # @form_url = admin_update_purchase_reception_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    @is_edit = true

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/purchases/reception/:id/history
  def history
    # Employee found by before_action

    @history = @reception.associated_audits
    @history.push(@reception.audits)
  end

  # Create
  def create
    updated_params = purchase_reception_params

    # Deleting blank spaces
    updated_params[:receipt_number] = updated_params[:receipt_number].strip
    updated_params[:status] = updated_params[:status].strip
    updated_params[:observations] = updated_params[:observations].strip
    # End Deleting blank spaces

    updated_params[:purchase_datetime] = updated_params[:purchase_datetime].to_datetime if updated_params[:purchase_datetime]

    # Fixing discount
    if updated_params[:discount]
      begin
        updated_params[:discount] = updated_params[:discount].to_d

      rescue
        updated_params[:discount] = 0.00
      end
    end

    is_edit = params[:is_edit] || false

    # If record is an edit
    if is_edit

      # Deleting blank spaces
      updated_params[:status] = "received"
      # End Deleting blank spaces

      # Validating detail with stock on Destroy
      json = JSON.parse(updated_params["purchase_details_attributes"].to_json) # Converting to Json
      # Iterating Json
      json.each do |item|
        # Item is being destroyed
        if item[1]["_destroy"] == "1"
          detail_id = item[1]["id"] || nil
          detail = PurchaseDetail.find(detail_id) || nil

          product_id = item[1]["product_id"] || nil
          product = Product.find(product_id) || nil

          # If detail has been found
          if detail
            # If product has been found
            if product
              # If purchase is active
              if detail.purchase.state
                # If sale is a reception
                if detail.purchase.status == "received"
                  # If the quantity is more than the stock
                  if (product.stock - detail.quantity) < 0
                    redirect_to admin_edit_purchase_reception_path(@reception), alert: t("purchase.stock_is_less", stock: detail.product.stock ,product: I18n.locale == :es ? detail.product.name_spanish : detail.product.name)
                    return

                    # If the quantity is less than the stock
                  else
                    puts "Stock is more than the quantity"

                    product.stock = product.stock - detail.quantity

                    returned = PurchaseDetail.new
                    returned.purchase_id = detail.purchase_id
                    returned.product_id = detail.product_id
                    returned.price = detail.price
                    returned.quantity = detail.quantity
                    returned.status = "returned"

                    if returned.save
                      puts "Return created on detail destroy"
                    end

                    # Trigger saving successfully
                    if product.save
                      puts "Stock updated on destroy"
                    end
                  end
                end
                # End If sale is a reception
              end
              # End If purchase is active
            end
            # End If product has been found
          end
          # End If detail has been found
        end
        # End Item is being destroyed
      end
      # End Iterating Json

    end
    # If record is an edit

    # If record was saved
    if @reception.update(updated_params)
      redirect_to admin_purchase_details_path(@reception.id), notice: t("alerts.updated", model: t("purchase.reception")) # Received

      # If record was not saved
    else
      @search_form_path = admin_edit_product_path(@reception)
      @form_url = admin_purchases_reception_path

      # @search_form_path = admin_new_purchase_reception_path(@reception)
      # @form_url = admin_purchases_reception_path

      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

      if is_edit
        @is_edit = true
        render :edit
        return
      end

      render :new
    end
  end

  # Deactive
  def deactive
    @reception.purchase_details.each do |detail|
      return if !update_stock(detail)
    end

    if @reception.update(state: false)
      redirect_to_back(false, admin_purchase_receptions_path, "purchase", "success")

    else
      redirect_to_back(false, admin_purchase_receptions_path, "purchase", "error")
    end
  end

  # Update product stock
  def update_stock(detail)
    product = Product.find(detail.product_id) || nil

    # If product has been found
    if product
      # If purchase is active
      if detail.purchase.state
        final_stock = product.stock - detail.quantity

        # If the new quantity is more than the stock
        if (final_stock) < 0
          redirect_to admin_purchase_details_path(detail.purchase_id), alert: "#{t('purchase.error_canceling_reception')}. #{t('purchase.stock_is_less', stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name)}"
          return false

          # If the new quantity is less than the stock
        else
          product.stock = final_stock

          returned = PurchaseDetail.new
          returned.purchase_id = detail.purchase_id
          returned.product_id = detail.product_id
          returned.price = detail.price
          returned.quantity = detail.quantity
          returned.status = "returned"

          if returned.save
            puts "Return created on detail deactivation"
          end
        end

        # Trigger saving successfully
        if product.save
          return true

          # Trigger saving failed
        else
          puts "Product stock not updated on deactivation"
        end
      end
      # End If purchase is active
    end
    # End If product has been found
  end
  # End Update product stock

  private

  # Set Purchase
  def set_purchase_reception
    @reception = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_receptions_path, alert: t("alerts.not_found", model: t("purchase.reception"))
  end

  def purchase_reception_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
