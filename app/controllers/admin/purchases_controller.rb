class Admin::PurchasesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  ########## ORDERS ##########

  # Find purchase order with Friendly_ID
  before_action :set_purchase_order, only: [:edit_order, :update_order, :active_order, :deactive_order, :history_order]
  # End Find purchase order with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create_order, :update_order, :active_order, :deactive_order,    :create_reception, :deactive_reception]
  # End Sync model DSL

  ########## RECEPTIONS ##########

  # Find purchase reception with Friendly_ID
  before_action :set_purchase_reception, only: [:new_reception, :edit_reception, :create_reception, :deactive_reception, :history_reception]
  # End Find purchase reception with Friendly_ID

  ########## RETURNS ##########

  # Find purchase return with Friendly_ID
  before_action :set_purchase_return, only: [:new_return, :new_loss, :create_return, :create_loss]
  # End Find purchase return with Friendly_ID

  # Authentication
  before_action :require_employee, :require_warehouse_supervisor
  # End Authentication

  ########## ORDERS ##########

  # /admin/purchases/orders
  def index_orders
    @orders = Purchase.search_order(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @orders.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "purchase-orders-#{file_time}"
    template = "admin/purchases/orders/index_pdf.html.haml"
    title_pdf = t("purchase.orders")
    # End PDF view configuration

    respond_to do |format|
      format.html do
        render "admin/purchases/orders/index"
      end

      format.js do
        render "admin/purchases/orders/index"
      end

      format.pdf do
        to_pdf(name_pdf, template, Purchase.orders, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/purchases/order/new
  def new_order
    @order = Purchase.new
    @order.discount = 0
    @order.receipt_number = "N/A"

    @search_form_path = admin_new_purchase_order_path(@order)
    @form_url = admin_purchase_order_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html do
        render "admin/purchases/orders/new"
      end

      format.js do
        render "admin/purchases/orders/new"
      end
    end
  end

  # admin/purchases/order/:id/edit
  def edit_order
    # Order found by before_action
    @order.discount = "%.2f" % @order.discount
    @order.discount = "0#{@order.discount.to_s.gsub! '.', ''}" if @order.discount < 10

    @search_form_path = admin_edit_purchase_order_path(@order)
    @form_url = admin_update_purchase_order_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html do
        render "admin/purchases/orders/edit"
      end

      format.js do
        render "admin/purchases/orders/edit"
      end
    end
  end

  # admin/purchases/order/:id/history
  def history_order
    # Employee found by before_action

    @history = @order.associated_audits
    @history.push(@order.audits)

    render "admin/purchases/orders/history"
  end

  # Create
  def create_order
    @order = Purchase.new(purchase_order_params)

    # Deleting blank spaces
    @order[:receipt_number] = @order[:receipt_number].strip
    @order[:status] = "ordered"
    @order[:observations] = @order[:observations].strip
    # End Deleting blank spaces

    @order[:purchase_datetime] = @order[:purchase_datetime].to_datetime if @order[:purchase_datetime]

    # Fixing discount
    if @order[:discount]
      begin
        @order[:discount] = @order[:discount].to_d

      rescue
        @order[:discount] = 0.00
      end
    end

    # If record was saved
    if @order.save
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.created", model: t("purchase.order"))

      # If record was not saved
    else
      @search_form_path = admin_new_purchase_order_path(@order)
      @form_url = admin_purchase_order_path

      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      # render :new_order

      respond_to do |format|
        format.html do
          render "admin/purchases/orders/new"
        end

        format.js do
          render "admin/purchases/orders/new"
        end
      end
    end
  end

  # Update
  def update_order
    updated_params = purchase_order_params

    # Deleting blank spaces
    updated_params[:receipt_number] = updated_params[:receipt_number].strip
    updated_params[:status] = "ordered"
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

    if @order.update(updated_params)
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.updated", model: t("purchase.order"))

    else
      @search_form_path = admin_edit_purchase_order_path(@order)
      @form_url = admin_update_purchase_order_path

      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      # render :edit_order

      respond_to do |format|
        format.html do
          render "admin/purchases/orders/edit"
        end

        format.js do
          render "admin/purchases/orders/edit"
        end
      end
    end
  end

  # Active
  def active_order
    if @order.update(state: true)
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.enabled", model: t("activerecord.models.purchase"))

    else
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.not_enabled", model: t("activerecord.models.purchase"))
    end
  end

  # Deactive
  def deactive_order
    if @order.update(state: false)
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.disabled", model: t("activerecord.models.purchase"))

    else
      redirect_to admin_purchase_details_path(@order.id), notice: t("alerts.not_disabled", model: t("activerecord.models.purchase"))
    end
  end

  ########## END ORDERS ##########


  ########## RECEPTIONS ##########

  # /admin/purchases/receptions
  def index_receptions
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
      format.html do
        render "admin/purchases/receptions/index"
      end

      format.js do
        render "admin/purchases/receptions/index"
      end

      format.pdf do
        to_pdf(name_pdf, template, Purchase.receptions, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/purchases/reception/new
  def new_reception
    @search_form_path = admin_new_purchase_reception_path(@reception)
    @form_url = admin_purchases_reception_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html do
        render "admin/purchases/receptions/new"
      end

      format.js do
        render "admin/purchases/receptions/new"
      end
    end
  end

  # admin/purchases/reception/:id/edit
  def edit_reception
    # Order found by before_action
    @reception.discount = "%.2f" % @reception.discount
    @reception.discount = "0#{@reception.discount.to_s.gsub! '.', ''}" if @reception.discount < 10

    @search_form_path = admin_edit_purchase_reception_path(@reception)
    @form_url = admin_purchases_reception_path
    # @form_url = admin_update_purchase_reception_path

    @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    @is_edit = true

    respond_to do |format|
      format.html do
        render "admin/purchases/receptions/edit"
      end

      format.js do
        render "admin/purchases/receptions/edit"
      end
    end
  end

  # admin/purchases/reception/:id/history
  def history_reception
    # Employee found by before_action

    @history = @reception.associated_audits
    @history.push(@reception.audits)

    render "admin/purchases/receptions/history"
  end

  # Create
  def create_reception
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

    end
    # If record is an edit

    # If record was saved
    if @reception.update(updated_params)
      redirect_to admin_purchase_details_path(@reception.id), notice: t("alerts.updated", model: t("purchase.reception")) # Received

      # If record was not saved
    else
      @search_form_path = admin_edit_purchase_reception_path(@reception)
      @form_url = admin_purchases_reception_path

      # @search_form_path = admin_new_purchase_reception_path(@reception)
      # @form_url = admin_purchases_reception_path

      @providers = Provider.search(params[:search_provider], "enabled-only").paginate(page: params[:providers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

      if is_edit
        @is_edit = true

        # render :edit_reception
        respond_to do |format|
          format.html do
            render "admin/purchases/receptions/edit"
          end

          format.js do
            render "admin/purchases/receptions/edit"
          end
        end

        return
      end

      # render :new_reception
      respond_to do |format|
        format.html do
          render "admin/purchases/receptions/new"
        end

        format.js do
          render "admin/purchases/receptions/new"
        end
      end
    end
  end

  # Deactive
  def deactive_reception
    @reception.purchase_details.each do |detail|
      return if !update_stock(detail)
    end

    if @reception.update(state: false)
      @reception.purchase_details.each do |detail|
        product = detail.product
        sync_update product
      end

      redirect_to admin_purchase_details_path(@reception.id), notice: t("alerts.disabled", model: t("activerecord.models.purchase"))

    else
      redirect_to admin_purchase_details_path(@reception.id), notice: t("alerts.not_disabled", model: t("activerecord.models.purchase"))
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
            puts "Purchase return created - on detail deactivation"
          end
        end

        # Trigger saving successfully
        if product.save
          return true

          # Trigger saving failed
        else
          puts "Product stock not updated - on detail deactivation (Purchase)"
        end
      end
      # End If purchase is active
    end
    # End If product has been found
  end
  # End Update product stock

  ########## END RECEPTIONS ##########


  ########## RETURNS ##########

  # admin/purchases/returns
  def index_returns
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
      format.html do
        render "admin/purchases/returns/index"
      end

      format.js do
        render "admin/purchases/returns/index"
      end
      format.pdf do
        to_pdf(name_pdf, template, PurchaseDetail.returned, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/purchases/reception/:id/return
  def new_return
    # Order found by before_action
    @return.discount = "%.2f" % @return.discount
    @return.discount = "0#{@return.discount.to_s.gsub! '.', ''}" if @return.discount < 10

    @search_form_path = admin_new_purchase_return_path(@return)
    @form_url = admin_purchase_return_path

    respond_to do |format|
      format.html do
        render "admin/purchases/returns/new"
      end

      format.js do
        render "admin/purchases/returns/new"
      end
    end
  end

  # admin/purchases/reception/:id/loss
  def new_loss
    # Order found by before_action
    @return.discount = "%.2f" % @return.discount
    @return.discount = "0#{@return.discount.to_s.gsub! '.', ''}" if @return.discount < 10

    @search_form_path = admin_new_purchase_loss_path(@return)
    @form_url = admin_purchase_loss_path

    @is_loss = true

    respond_to do |format|
      format.html do
        render "admin/purchases/returns/new"
      end

      format.js do
        render "admin/purchases/returns/new"
      end
    end
  end

  # Create
  def create_return
    updated_params = purchase_return_params

    # Deleting blank spaces
    updated_params[:receipt_number] = updated_params[:receipt_number].strip
    updated_params[:observations] = updated_params[:observations].strip
    updated_params[:status] = "received"
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
              # If purchase is a reception
              if detail.purchase.status == "received"
                # If the quantity is more than the stock
                if (product.stock - detail.quantity) < 0
                  redirect_to admin_new_purchase_return_path(@return), alert: t("purchase.stock_is_less", stock: detail.product.stock ,product: I18n.locale == :es ? detail.product.name_spanish : detail.product.name)
                  return

                  # If the quantity is less than the stock
                else
                  puts "Stock is more than the quantity - on create return"

                  product.stock = product.stock - detail.quantity

                  returned = PurchaseDetail.new
                  returned.purchase_id = detail.purchase_id
                  returned.product_id = detail.product_id
                  returned.price = detail.price
                  returned.quantity = detail.quantity
                  returned.status = "returned"
                  returned.loss_expiration = false

                  if returned.save
                    puts "Purchase return created on detail destroy - on create return"
                  end

                  # Trigger saving successfully
                  if product.save
                    puts "Stock updated on destroy - on create return"
                  end
                end
              end
              # End If purchase is a reception
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

    # If record was saved
    if @return.update(updated_params)
      @return.purchase_details.each do |detail|
        product = detail.product
        verify_stock(product)
        sync_update product
      end

      redirect_to admin_purchase_returns_path, notice: t("alerts.created", model: t("sale.return")) # Returned

      # If record was not saved
    else
      @search_form_path = admin_new_purchase_return_path(@return)
      @form_url = admin_purchase_return_path

      # render :new_reception
      respond_to do |format|
        format.html do
          render "admin/purchases/returns/new"
        end

        format.js do
          render "admin/purchases/returns/new"
        end
      end
    end
  end

  # Create
  def create_loss
    updated_params = purchase_return_params

    # Deleting blank spaces
    updated_params[:receipt_number] = updated_params[:receipt_number].strip
    updated_params[:observations] = updated_params[:observations].strip
    updated_params[:status] = "received"
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
              # If purchase is a reception
              if detail.purchase.status == "received"
                # If the quantity is more than the stock
                if (product.stock - detail.quantity) < 0
                  redirect_to admin_new_purchase_return_path(@return), alert: t("purchase.stock_is_less", stock: detail.product.stock ,product: I18n.locale == :es ? detail.product.name_spanish : detail.product.name)
                  return

                  # If the quantity is less than the stock
                else
                  puts "Stock is more than the quantity - on create loss"

                  product.stock = product.stock - detail.quantity

                  returned = PurchaseDetail.new
                  returned.purchase_id = detail.purchase_id
                  returned.product_id = detail.product_id
                  returned.price = detail.price
                  returned.quantity = detail.quantity
                  returned.status = "returned"
                  returned.loss_expiration = true

                  if returned.save
                    puts "Purchase return created on detail destroy - on create loss"
                  end

                  # Trigger saving successfully
                  if product.save
                    puts "Stock updated on destroy - on create loss"
                  end
                end
              end
              # End If purchase is a reception
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

    # If record was saved
    if @return.update(updated_params)
      @return.purchase_details.each do |detail|
        product = detail.product
        verify_stock(product)
        sync_update product
      end

      redirect_to admin_purchase_returns_path, notice: t("alerts.created", model: t("sale.return")) # Returned

      # If record was not saved
    else
      @search_form_path = admin_new_purchase_loss_path(@return)
      @form_url = admin_purchase_loss_path
      @is_loss = true

      # render :new_reception
      respond_to do |format|
        format.html do
          render "admin/purchases/returns/new"
        end

        format.js do
          render "admin/purchases/returns/new"
        end
      end
    end
  end

  ########## END RETURNS ##########

  # Verify product stock
  def verify_stock(product)
    # Verify if current stock is greather than the min stock
    if (product.stock < product.stock_min)
      # Creating new notification
      notification = Notification.new
      notification.message = "scarce_product"
      notification.path = "#{admin_product_url(product)}"
      notification.read_by = "false"

      if notification.save
        puts "Notification saved"
        sync_new notification

      else
        puts "Notification not saved"
      end
    end
  end
  # End Verify product stock

  private

  ########## ORDERS ##########

  # Set Purchase
  def set_purchase_order
    @order = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_orders_path, alert: t("alerts.not_found", model: t("purchase.order"))
  end

  def purchase_order_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end

  ########## RECEPTIONS ##########

  # Set Purchase
  def set_purchase_reception
    @reception = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_receptions_path, alert: t("alerts.not_found", model: t("purchase.reception"))
  end

  def purchase_reception_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end

  ########## RETURNS ##########

  # Set Purchase
  def set_purchase_return
    @return = Purchase.find(params[:id])

  rescue
    redirect_to admin_purchase_returns_path, alert: t("alerts.not_found", model: t("purchase.return"))
  end

  def purchase_return_params
    params.require(:purchase).permit(:purchase_datetime, :receipt_number, :status, :discount, :provider_id, :employee_id, :observations, purchase_details_attributes: PurchaseDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
