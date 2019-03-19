class SaleDetail < ApplicationRecord
  # Associations
  belongs_to :sale
  belongs_to :product
  # End Associations

  # Nested attributes
  accepts_nested_attributes_for :sale
  # End Nested attributes

  # Audit
  audited associated_with: :sale
  # End Audit

  # Render sync
  sync :all
  # sync_touch :sale
  # End Render sync

  ## Callbacks

  before_validation :update_stock_create, on: :create
  before_validation :update_stock, on: :update

  # Update product stock on create
  def update_stock_create
    product = Product.find(self.product_id) || nil

    # If product has been found
    if product

      # If is not a return
      if self.status != "returned"
        # Current stock - Sale quantity
        final_stock = product.stock - self.quantity

        # If the sale quantity exceed the stock
        if (final_stock) < 0
          self.errors.add(:quantity, I18n.t("sale.stock_is_less_sale", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
          return

          #  If the sale quantity is less than the stock
        else
          # Set new stock to product
          product.stock = final_stock

          # Saving product new stock
          if product.save
            puts "Product stock updated on sale detail create"

            # Product stock not saved
          else
            puts "Product stock not updated on sale detail create"
          end
          # End Saving product new stock
        end
        # End If product stock is less than the quantity to sale
      end
      # End If is not a return
    end
    # End If product has been found
  end
  # End Update product stock on create

  # Update product stock on update
  def update_stock
    product = Product.find(self.product_id) || nil

    # If product has been found
    if product
      # If sale is active
      if self.sale.state
        old_quantity = self.changes["quantity"][0] if changes["quantity"]
        old_quantity = 0 if !old_quantity

        old_status = self.changes["status"][0] if changes["status"]
        old_status = "invoiced" if !old_status

        # If is an invoice or a delivery
        if (self.status == "invoiced" || self.status == "delivered")
          # Current stock - Old Sale quantity + New Sale quantity
          final_stock =  product.stock + old_quantity - self.quantity

          # If the new quantity exceed the stock
          if final_stock < 0
            self.errors.add(:quantity, I18n.t("sale.stock_is_less_sale", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
            return

            # If the new quantity is less than the stock
          else
            # Set new stock to product
            product.stock = final_stock

            # If quantity was reduced
            if self.quantity <= old_quantity
              # Save new return
              returned = SaleDetail.new
              returned.sale_id = self.sale_id
              returned.product_id = self.product_id
              returned.price = self.price
              returned.quantity = self.quantity
              returned.status = "returned"

              # Reset params
              self.quantity = (old_quantity - self.quantity)

              # Saving return
              if returned.save
                puts "Return created on sale detail update"

                # Return not saved
              else
                puts "Return not created on sale detail update"
              end
              # End Saving return

              # If quantity was not reduced
            else
              # Quantity to return is more than the quantity sold
              self.errors.add(:quantity, I18n.t("sale.quantity_more_than_sold", quantity: self.quantity, product: I18n.locale == :es ? product.name_spanish : product.name))
              return
            end
            # End If quantity was reduced

            # Saving product new stock
            if product.save
              puts "Product stock updated on sale detail update"

              # Product stock not saved
            else
              puts "Product stock not updated on sale detail update"
            end
            # End Saving product new stock
          end
          # End If the new quantity exceed the stock
        end
        # End If is an invoice or a delivery
      end
      # End If sale is active
    end
    # End If product has been found
  end
  # End Update product stock on update

  ## End Callbacks

  # Search orders
  def self.search_orders(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").ordered.not_returned.not_pending

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).ordered.not_returned.not_pending

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).ordered.not_returned.not_pending
    end
  end
  # End Search orders

  # Search invoices
  def self.search_invoices(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").invoiced.not_returned.not_pending

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).invoiced.not_returned.not_pending

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).invoiced.not_returned.not_pending
    end
  end
  # End Search invoices

  # Search shipments
  def self.search_shipments(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").shipped.not_returned.not_pending

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).shipped.not_returned.not_pending

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).shipped.not_returned.not_pending
    end
  end
  # End Search shipments

  # Search deliveries
  def self.search_deliveries(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").delivered.not_returned.not_pending

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).delivered.not_returned.not_pending

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).delivered.not_returned.not_pending
    end
  end
  # End Search deliveries

  # Search returns
  def self.search_returns(search)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search)", search: "%#{search}%").returned

    else
      returned
    end
  end
  # End Search returns

  # Search price lists
  def self.search_price_lists(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").price_list.not_returned.not_pending

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).price_list.not_returned.not_pending

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).price_list.not_returned.not_pending
    end
  end
  # End Search price lists

  # Search
  def self.search(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search OR sale_details.status LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%")

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id)

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).not_returned.not_pending
    end
  end
  # End Search

  # Presence validation
  validates :product_id, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  # End  Presence validation

  # Length validation
  validates :status, length: { maximum: 255 }
  # End Length validation

  # Numericality validation
  # validates :price, numericality: {greater_than_or_equal_to: 0}
  # validates :quantity, numericality: {greater_than: 0}
  # End Numericality validation

  ## Scopes
  scope :not_returned, -> { where("(sale_details.status != 'returned')") }
  scope :not_pending, -> { where("(sale_details.status != 'pending')") }
  scope :returned, -> { where("(sale_details.status = 'returned')") }
  scope :ordered, -> { where("(sale_details.status = 'ordered')") }
  scope :invoiced, -> { where("(sale_details.status = 'invoiced')") }
  scope :shipped, -> { where("(sale_details.status = 'shipped')") }
  scope :delivered, -> { where("(sale_details.status = 'delivered')") }
  scope :price_list, -> { where("(sale_details.status = 'price_list')") }
  ## End Scopes
end
