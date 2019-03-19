class Admin::SalesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Sync model DSL
  enable_sync only: [:create_invoice, :update_invoice, :deactive_invoice, :new_shipment, :new_delivery, :update_delivery, :deactive_delivery]
  # End Sync model DSL

  ########## ORDERS ##########

  # Find sale order with Friendly_ID
  before_action :set_sale_order, only: [:history_order]
  # End Find sale order with Friendly_ID

  ########## INVOICES ##########

  # Find sale invoice with Friendly_ID
  before_action :set_sale_invoice, only: [:edit_invoice, :update_invoice, :deactive_invoice, :history_invoice]
  # End Find sale invoice with Friendly_ID

  ########## SHIPMENTS ##########

  # Find sale order with Friendly_ID
  before_action :set_sale_shipment, only: [:new_shipment, :history_shipment]
  # End Find sale order with Friendly_ID

  ########## DELIVERIES ##########

  # Find sale order with Friendly_ID
  before_action :set_sale_delivery, only: [:new_delivery, :edit_delivery, :update_delivery, :deactive_delivery, :history_delivery]
  # End Find sale order with Friendly_ID

  ########## RETURNS ##########

  # Find sale order with Friendly_ID
  before_action :set_sale_return, only: [:new_invoice_return, :new_delivery_return, :create_invoice_return, :create_delivery_return]
  # End Find sale order with Friendly_ID

  # Authentication
  before_action :require_employee, :require_seller_driver

  before_action :require_seller, only: [:index_invoices, :new_invoice, :edit_invoice, :create_invoice, :update_invoice, :deactive_invoice, :history_invoice, :index_returns]

  # before_action :require_driver, only: [:index_shipments, :new_shipment, :history_shipment]
  # End Authentication

  ########## ORDERS ##########

  # /admin/sales/orders
  def index_orders
    @orders = Sale.search_order(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Orders with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @orders.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-orders-#{file_time}"
    template = "admin/sales/orders/index_pdf.html.haml"
    title_pdf = t("sale.orders")
    # End PDF view configuration

    respond_to do |format|
      format.html do
        render "admin/sales/orders/index"
      end

      format.js do
        render "admin/sales/orders/index"
      end

      format.pdf do
        to_pdf(name_pdf, template, Sale.orders, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/order/:id/history
  def history_order
    # Sale found by before_action

    @history = @order.associated_audits
    @history.push(@order.audits)

    render "admin/sales/orders/history"
  end

  ########## END ORDERS ##########


  ########## INVOICES ##########

  # /admin/sales/invoices
  def index_invoices
    @invoices = Sale.search_invoice(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Invoices with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @invoices.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-invoices-#{file_time}"
    template = "admin/sales/invoices/index_pdf.html.haml"
    title_pdf = t("sale.invoices")
    # End PDF view configuration

    respond_to do |format|
      format.html do
        render "admin/sales/invoices/index"
      end

      format.js do
        render "admin/sales/invoices/index"
      end

      format.pdf do
        to_pdf(name_pdf, template, Sale.invoices, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/invoice/new
  def new_invoice
    @invoice = Sale.new
    @invoice.discount = 0

    @search_form_path = admin_new_sale_invoice_path(@invoice)
    @form_url = admin_sale_invoice_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "with-stock-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html do
        render "admin/sales/invoices/new"
      end

      format.js do
        render "admin/sales/invoices/new"
      end
    end
  end

  # admin/sales/invoice/:id/edit
  def edit_invoice
    # Order found by before_action
    @invoice.discount = "%.2f" % @invoice.discount
    @invoice.discount = "0#{@invoice.discount.to_s.gsub! '.', ''}" if @invoice.discount < 10

    @search_form_path = admin_edit_sale_invoice_path(@invoice)
    @form_url = admin_update_sale_invoice_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "with-stock-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    @is_edit = true

    respond_to do |format|
      format.html do
        render "admin/sales/invoices/edit"
      end

      format.js do
        render "admin/sales/invoices/edit"
      end
    end
  end

  # admin/sales/invoice/:id/history
  def history_invoice
    # Employee found by before_action

    @history = @invoice.associated_audits
    @history.push(@invoice.audits)

    render "admin/sales/invoices/history"
  end

  # Create
  def create_invoice
    @invoice = Sale.new(sale_invoice_params)

    @invoice[:delivery_status] = "received"
    @invoice[:status] = "invoiced"

    @invoice[:payment_method] = "cash"
    @invoice[:payment_reference] = "*****"
    @invoice[:paid] = true

    # Deleting blank spaces
    @invoice[:observations] = @invoice[:observations].strip
    # End Deleting blank spaces

    @invoice[:sale_datetime] = @invoice[:sale_datetime].to_datetime if @invoice[:sale_datetime]

    # Fixing discount
    if @invoice[:discount]
      begin
        @invoice[:discount] = @invoice[:discount].to_d

      rescue
        @invoice[:discount] = 0.00
      end
    end

    # If record was saved
    if @invoice.save
      redirect_to admin_sale_details_path(@invoice.id), notice: t("alerts.created", model: t("sale.invoice"))

      # If record was not saved
    else
      @search_form_path = admin_new_sale_invoice_path(@invoice)
      @form_url = admin_sale_invoice_path

      @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "with-stock-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      # render :new_invoice

      respond_to do |format|
        format.html do
          render "admin/sales/invoices/new"
        end

        format.js do
          render "admin/sales/invoices/new"
        end
      end
    end
  end

  # Update
  def update_invoice
    updated_params = sale_invoice_params

    # Deleting blank spaces
    updated_params[:observations] = updated_params[:observations].strip
    # End Deleting blank spaces

    updated_params[:sale_datetime] = updated_params[:sale_datetime].to_datetime if updated_params[:sale_datetime]

    # Fixing discount
    if updated_params[:discount]
      begin
        updated_params[:discount] = updated_params[:discount].to_d

      rescue
        updated_params[:discount] = 0.00
      end
    end

    if @invoice.update(updated_params)
      redirect_to admin_sale_details_path(@invoice.id), notice: t("alerts.updated", model: t("sale.invoice"))

    else
      @search_form_path = admin_edit_sale_invoice_path(@invoice)
      @form_url = admin_update_sale_invoice_path

      @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "with-stock-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      # render :edit_invoice

      respond_to do |format|
        format.html do
          render "admin/sales/invoices/edit"
        end

        format.js do
          render "admin/sales/invoices/edit"
        end
      end
    end
  end

  # Deactive
  def deactive_invoice
    @invoice.sale_details.each do |detail|
      return if !update_stock(detail)
    end

    if @invoice.update(state: false)
      redirect_to admin_sale_details_path(@invoice.id), notice: t("alerts.disabled", model: t("activerecord.models.sale"))

    else
      redirect_to admin_sale_details_path(@invoice.id), notice: t("alerts.not_disabled", model: t("activerecord.models.sale"))
    end
  end

  # Update product stock
  def update_stock(detail)
    product = Product.find(detail.product_id) || nil

    # If product has been found
    if product
      # If sale is active
      if detail.sale.state
        final_stock = product.stock + detail.quantity

        product.stock = final_stock

        returned = SaleDetail.new
        returned.sale_id = detail.sale_id
        returned.product_id = detail.product_id
        returned.price = detail.price
        returned.quantity = detail.quantity
        returned.status = "returned"

        if returned.save
          puts "Sale return created on detail deactivation"
        end

        # Trigger saving successfully
        if product.save
          return true

          # Trigger saving failed
        else
          puts "Product stock not updated on deactivation (Sale)"
        end
      end
      # End If sale is active
    end
    # End If product has been found
  end
  # End Update product stock

  ########## END INVOICES ##########


  ########## SHIPMENTS ##########

  # /admin/sales/shipments
  def index_shipments
    @shipments = Sale.search_shipment(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Shipments with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @shipments.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-shipments-#{file_time}"
    template = "admin/sales/shipments/index_pdf.html.haml"
    title_pdf = t("sale.shipments")
    # End PDF view configuration

    respond_to do |format|
      format.html do
        render "admin/sales/shipments/index"
      end

      format.js do
        render "admin/sales/shipments/index"
      end

      format.pdf do
        to_pdf(name_pdf, template, Sale.shipments, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/shipment/:id/history
  def history_shipment
    # Sale found by before_action

    @history = @shipment.associated_audits
    @history.push(@shipment.audits)

    render "admin/sales/shipments/history"
  end

  def new_shipment
    @shipment.status = "shipped"
    @shipment.delivery_status = "shipped"

    @shipment.employee_id = current_employee.id

    @shipment.sale_details.each do |detail|
      detail.status = "shipped"
    end

    if @shipment.save
      # redirect_to admin_sale_shipments_path, notice: "Orden enviada correctamente"
      redirect_to admin_sale_shipments_path, notice: t("sale.order_shipped_correctly")

    else
      # redirect_to admin_sale_details_path(@shipment.id), error: "No se pudo enviar la orden"
      redirect_to admin_sale_shipments_path, error: t("sale.problem_shipping_order")
    end
  end

  ########## SHIPMENTS ##########


  ########## DELIVERIES ##########

  # /admin/sales/deliveries
  def index_deliveries
    @deliveries = Sale.search_delivery(params[:search], params[:show]).paginate(page: params[:page], per_page: 15) # Shipments with pagination
    @show_all = params[:show] == "all" ? true : false # View All (Enabled and Disabled)
    @count = @deliveries.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "sale-deliveries-#{file_time}"
    template = "admin/sales/deliveries/index_pdf.html.haml"
    title_pdf = t("sale.deliveries")
    # End PDF view configuration

    respond_to do |format|
      format.html do
        render "admin/sales/deliveries/index"
      end

      format.js do
        render "admin/sales/deliveries/index"
      end

      format.pdf do
        to_pdf(name_pdf, template, Sale.deliveries, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/delivery/:id/edit
  def edit_delivery
    # Order found by before_action
    @delivery.discount = "%.2f" % @delivery.discount
    @delivery.discount = "0#{@delivery.discount.to_s.gsub! '.', ''}" if @delivery.discount < 10

    @search_form_path = admin_edit_sale_delivery_path(@delivery)
    @form_url = admin_update_sale_delivery_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "with-stock-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    @is_edit = true

    respond_to do |format|
      format.html do
        render "admin/sales/deliveries/edit"
      end

      format.js do
        render "admin/sales/deliveries/edit"
      end
    end
  end

  # admin/sales/delivery/:id/history
  def history_delivery
    # Sale found by before_action

    @history = @delivery.associated_audits
    @history.push(@delivery.audits)

    render "admin/sales/deliveries/history"
  end

  def new_delivery
    @delivery.status = "delivered"
    @delivery.delivery_status = "delivered"

    @delivery.employee_id = current_employee.id

    if !@delivery.paid
      @delivery.paid = true
    end

    @delivery.sale_details.each do |detail|
      detail.status = "delivered"
    end

    if @delivery.save
      # redirect_to admin_sale_deliveries_path, notice: "Orden enviada correctamente"
      redirect_to admin_sale_deliveries_path, notice: t("sale.order_received_correctly")

    else
      # redirect_to admin_sale_details_path(@delivery.id), error: "No se pudo enviar la orden"
      redirect_to admin_sale_deliveries_path, error: t("sale.problem_receiving_order")
    end
  end

  # Update
  def update_delivery
    updated_params = sale_delivery_params

    # Deleting blank spaces
    updated_params[:observations] = updated_params[:observations].strip
    # End Deleting blank spaces

    updated_params[:sale_datetime] = updated_params[:sale_datetime].to_datetime if updated_params[:sale_datetime]

    # Fixing discount
    if updated_params[:discount]
      begin
        updated_params[:discount] = updated_params[:discount].to_d

      rescue
        updated_params[:discount] = 0.00
      end
    end

    if @delivery.update(updated_params)
      redirect_to admin_sale_details_path(@delivery.id), notice: t("alerts.updated", model: t("sale.delivery"))

    else
      @search_form_path = admin_edit_sale_delivery_path(@delivery)
      @form_url = admin_update_sale_delivery_path

      @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "with-stock-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      # render :edit_delivery

      respond_to do |format|
        format.html do
          render "admin/sales/deliveries/edit"
        end

        format.js do
          render "admin/sales/deliveries/edit"
        end
      end
    end
  end

  # Deactive
  def deactive_delivery
    @delivery.sale_details.each do |detail|
      return if !update_stock(detail)
    end

    if @delivery.update(state: false)
      redirect_to admin_sale_details_path(@delivery.id), notice: t("alerts.disabled", model: t("activerecord.models.sale"))

    else
      redirect_to admin_sale_details_path(@delivery.id), notice: t("alerts.not_disabled", model: t("activerecord.models.sale"))
    end
  end

  ########## DELIVERIES ##########

  ########## RETURNS ##########

  # admin/sales/returns
  def index_returns
    @returns = SaleDetail.search_returns(params[:search]).paginate(page: params[:page], per_page: 15) # Returns with pagination
    @count = @returns.count

    # PDF view configuration
    current_lang = params[:lang]
    I18n.locale = current_lang

    datetime =  Time.zone.now
    file_time = datetime.strftime("%m%d%Y")

    name_pdf = "returns-#{file_time}"
    template = "admin/sales/returns/index_pdf.html.haml"
    title_pdf = t("header.navigation.returns")
    # End PDF view configuration

    respond_to do |format|
      format.html do
        render "admin/sales/returns/index"
      end

      format.js do
        render "admin/sales/returns/index"
      end
      format.pdf do
        to_pdf(name_pdf, template, SaleDetail.returns, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/invoice/:id/return
  def new_invoice_return
    # Order found by before_action
    @return.discount = "%.2f" % @return.discount
    @return.discount = "0#{@return.discount.to_s.gsub! '.', ''}" if @return.discount < 10

    @search_form_path = admin_new_sale_invoice_return_path(@return)
    @form_url = admin_sale_invoice_return_path

    respond_to do |format|
      format.html do
        render "admin/sales/returns/new"
      end

      format.js do
        render "admin/sales/returns/new"
      end
    end
  end

  # admin/sales/delivery/:id/return
  def new_delivery_return
    # Order found by before_action
    @return.discount = "%.2f" % @return.discount
    @return.discount = "0#{@return.discount.to_s.gsub! '.', ''}" if @return.discount < 10

    @search_form_path = admin_new_sale_delivery_return_path(@return)
    @form_url = admin_sale_delivery_return_path
    @is_delivery = true

    respond_to do |format|
      format.html do
        render "admin/sales/returns/new"
      end

      format.js do
        render "admin/sales/returns/new"
      end
    end
  end

  # Create
  def create_invoice_return
    updated_params = sale_return_params

    # Deleting blank spaces
    updated_params[:observations] = updated_params[:observations].strip
    updated_params[:status] = "invoiced"
    # End Deleting blank spaces

    updated_params[:sale_datetime] = updated_params[:sale_datetime].to_datetime if updated_params[:sale_datetime]

    # Fixing discount
    if updated_params[:discount]
      begin
        updated_params[:discount] = updated_params[:discount].to_d

      rescue
        updated_params[:discount] = 0.00
      end
    end

    # Validating detail with stock on Destroy
    json = JSON.parse(updated_params["sale_details_attributes"].to_json) # Converting to Json

    # Iterating Json
    json.each do |item|
      # Item is being destroyed
      if item[1]["_destroy"] == "1"
        detail_id = item[1]["id"] || nil
        detail = SaleDetail.find(detail_id) || nil

        product_id = item[1]["product_id"] || nil
        product = Product.find(product_id) || nil

        # If detail has been found
        if detail
          # If product has been found
          if product
            # If sale is active
            if detail.sale.state
              # If sale is a invoice
              if detail.sale.status == "invoiced"
                # If the quantity is more than the stock
                if (product.stock - detail.quantity) < 0
                  redirect_to admin_new_sale_invoice_return_path(@return), alert: t("sale.stock_is_less", stock: detail.product.stock ,product: I18n.locale == :es ? detail.product.name_spanish : detail.product.name)
                  return

                  # If the quantity is less than the stock
                else
                  puts "Stock is more than the quantity - on create return (invoice)"

                  product.stock = product.stock - detail.quantity

                  returned = SaleDetail.new
                  returned.sale_id = detail.sale_id
                  returned.product_id = detail.product_id
                  returned.price = detail.price
                  returned.quantity = detail.quantity
                  returned.status = "returned"

                  if returned.save
                    puts "Sale return created on detail destroy - on create return (invoice)"
                  end

                  # Trigger saving successfully
                  if product.save
                    puts "Stock updated on destroy - on create return (invoice)"
                  end
                end
              end
              # End If sale is a invoice
            end
            # End If sale is active
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
      @return.sale_details.each do |detail|
        product = detail.product
        sync_update product
      end

      redirect_to admin_sale_returns_path, notice: t("alerts.created", model: t("sale.return")) # Returned

      # If record was not saved
    else
      @search_form_path = admin_new_sale_invoice_return_path(@return)
      @form_url = admin_sale_invoice_return_path

      # render :new_reception
      respond_to do |format|
        format.html do
          render "admin/sales/returns/new"
        end

        format.js do
          render "admin/sales/returns/new"
        end
      end
    end
  end

  # Create
  def create_delivery_return
    updated_params = sale_return_params

    # Deleting blank spaces
    updated_params[:observations] = updated_params[:observations].strip
    updated_params[:status] = "delivered"
    # End Deleting blank spaces

    updated_params[:sale_datetime] = updated_params[:sale_datetime].to_datetime if updated_params[:sale_datetime]

    # Fixing discount
    if updated_params[:discount]
      begin
        updated_params[:discount] = updated_params[:discount].to_d

      rescue
        updated_params[:discount] = 0.00
      end
    end

    # Validating detail with stock on Destroy
    json = JSON.parse(updated_params["sale_details_attributes"].to_json) # Converting to Json

    # Iterating Json
    json.each do |item|
      # Item is being destroyed
      if item[1]["_destroy"] == "1"
        detail_id = item[1]["id"] || nil
        detail = SaleDetail.find(detail_id) || nil

        product_id = item[1]["product_id"] || nil
        product = Product.find(product_id) || nil

        # If detail has been found
        if detail
          # If product has been found
          if product
            # If sale is active
            if detail.sale.state
              # If sale is a delivery
              if detail.sale.status == "delivered"
                # If the quantity is more than the stock
                if (product.stock - detail.quantity) < 0
                  redirect_to admin_new_sale_delivery_return_path(@return), alert: t("sale.stock_is_less", stock: detail.product.stock ,product: I18n.locale == :es ? detail.product.name_spanish : detail.product.name)
                  return

                  # If the quantity is less than the stock
                else
                  puts "Stock is more than the quantity - on create return (delivery)"

                  product.stock = product.stock - detail.quantity

                  returned = SaleDetail.new
                  returned.sale_id = detail.sale_id
                  returned.product_id = detail.product_id
                  returned.price = detail.price
                  returned.quantity = detail.quantity
                  returned.status = "returned"

                  if returned.save
                    puts "Sale return created on detail destroy - on create return (delivery)"
                  end

                  # Trigger saving successfully
                  if product.save
                    puts "Stock updated on destroy - on create return (delivery)"
                  end
                end
              end
              # End If sale is a delivery
            end
            # End If sale is active
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
      @return.sale_details.each do |detail|
        product = detail.product
        sync_update product
      end

      redirect_to admin_sale_returns_path, notice: t("alerts.created", model: t("sale.return")) # Returned

      # If record was not saved
    else
      @search_form_path = admin_new_sale_delivery_return_path(@return)
      @form_url = admin_sale_delivery_return_path
      @is_delivery = true

      # render :new_reception
      respond_to do |format|
        format.html do
          render "admin/sales/returns/new"
        end

        format.js do
          render "admin/sales/returns/new"
        end
      end
    end
  end

  ########## END RETURNS ##########

  private

  ########## ORDERS ##########

  # Set Sale
  def set_sale_order
    @order = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_orders_path, alert: t("alerts.not_found", model: t("sale.order"))
  end

  ########## INVOICES ##########

  # Set Sale
  def set_sale_invoice
    @invoice = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_invoices_path, alert: t("alerts.not_found", model: t("sale.invoice"))
  end

  def sale_invoice_params
    params.require(:sale).permit(:sale_datetime, :status, :delivery_status, :payment_method, :payment_reference, :paid, :discount, :customer_id, :employee_id, :observations, sale_details_attributes: SaleDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end

  ########## SHIPMENTS ##########

  # Set Sale
  def set_sale_shipment
    @shipment = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_shipments_path, alert: t("alerts.not_found", model: t("sale.shipment"))
  end

  ########## DELIVERIES ##########

  # Set Sale
  def set_sale_delivery
    @delivery = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_deliveries_path, alert: t("alerts.not_found", model: t("sale.delivery"))
  end

  def sale_delivery_params
    params.require(:sale).permit(:sale_datetime, :status, :delivery_status, :payment_method, :payment_reference, :paid, :discount, :customer_id, :employee_id, :observations, sale_details_attributes: SaleDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end

  ########## RETURNS ##########

  # Set Sale
  def set_sale_return
    @return = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_returns_path, alert: t("alerts.not_found", model: t("sale.return"))
  end

  def sale_return_params
    params.require(:sale).permit(:sale_datetime, :status, :delivery_status, :payment_method, :payment_reference, :paid, :discount, :customer_id, :employee_id, :observations, sale_details_attributes: SaleDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
