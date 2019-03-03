class Admin::Sales::InvoicesController < ApplicationController
  # Admin layout
  layout "admin/application"
  # End Admin layout

  # Find sale invoice with Friendly_ID
  before_action :set_sale_invoice, only: [:show, :edit, :update, :deactive, :history]
  # End Find sale invoice with Friendly_ID

  # Sync model DSL
  enable_sync only: [:create, :update, :deactive]
  # End Sync model DSL

  # Authentication
  # before_action :require_employee
  # End Authentication

  # /admin/sales/invoices
  def index
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
      format.html
      format.js
      format.pdf do
        to_pdf(name_pdf, template, Sale.all, I18n.l(datetime), title_pdf)
      end
    end
  end

  # admin/sales/invoice/new
  def new
    @invoice = Sale.new
    @invoice.discount = 0

    @search_form_path = admin_new_sale_invoice_path(@invoice)
    @form_url = admin_sales_invoice_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/sales/invoice/:id/edit
  def edit
    # Order found by before_action
    @invoice.discount = "%.2f" % @invoice.discount
    @invoice.discount = "0#{@invoice.discount.to_s.gsub! '.', ''}" if @invoice.discount < 10

    @search_form_path = admin_edit_sale_invoice_path(@invoice)
    @form_url = admin_sales_invoice_path
    # @form_url = admin_update_sale_invoice_path

    @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
    @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination

    @is_edit = true

    respond_to do |format|
      format.html
      format.js
    end
  end

  # admin/sales/invoice/:id/history
  def history
    # Employee found by before_action

    @history = @invoice.associated_audits
    @history.push(@invoice.audits)
  end

  # Create
  def create
    @invoice = Sale.new(sale_invoice_params)
    @invoice.payment_method = "-"
    @invoice.payment_reference = "-"
    @invoice.paid = true

    # Deleting blank spaces
    @invoice[:delivery_status] = @invoice[:delivery_status].strip
    @invoice[:status] = "invoiced"
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
      @form_url = admin_sales_invoice_path

      @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      render :new
    end
  end


  # Update
  def update
    # Deleting blank spaces
    @invoice[:delivery_status] = @invoice[:delivery_status].strip
    @invoice[:status] = "invoiced"
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

    # Validating detail with stock on Destroy
    json = JSON.parse(sale_invoice_params["sale_details_attributes"].to_json) # Converting to Json
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
              # If sale is an invoiced
              if detail.sale.status == "invoiced"
                puts "Stock is more than the quantity"

                product.stock = product.stock - detail.quantity

                returned = SaleDetail.new
                returned.sale_id = detail.sale_id
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
              # End If sale is an invoiced
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

    if @invoice.update(sale_invoice_params)
      redirect_to admin_sale_details_path(@invoice.id), notice: t("alerts.updated", model: t("sale.invoice"))

    else
      @search_form_path = admin_edit_product_path(@invoice)
      @form_url = admin_update_sale_invoice_path

      @customers = Customer.search(params[:search_customer], "enabled-only").paginate(page: params[:customers_page], per_page: 5) # Providers with pagination
      @products = Product.search(params[:search_product], "enabled-only").paginate(page: params[:products_page], per_page: 5) # Products with pagination
      render :edit
    end
  end

  # Deactive
  def deactive
    @invoice.sale_details.each do |detail|
      return if !update_stock(detail)
    end

    if @invoice.update(state: false)
      redirect_to_back(false, admin_sale_invoices_path, "sale", "success")

    else
      redirect_to_back(false, admin_sale_invoices_path, "sale", "error")
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
          puts "Return created on detail deactivation"
        end

        # Trigger saving successfully
        if product.save
          return true

          # Trigger saving failed
        else
          puts "Product stock not updated on deactivation"
        end
      end
      # End If sale is active
    end
    # End If product has been found
  end
  # End Update product stock

  private

  # Set Sale
  def set_sale_invoice
    @invoice = Sale.find(params[:id])

  rescue
    redirect_to admin_sale_invoices_path, alert: t("alerts.not_found", model: t("sale.invoice"))
  end

  def sale_invoice_params
    params.require(:sale).permit(:sale_datetime, :status, :delivery_status, :payment_method, :payment_reference, :paid, :discount, :customer_id, :employee_id, :observations, sale_details_attributes: SaleDetail.attribute_names.map(&:to_sym).push(:_destroy))
  end
end
