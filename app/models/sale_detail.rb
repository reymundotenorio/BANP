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

  before_validation :update_stock, on: :update
  before_validation :update_stock_create, on: :create

  # Update product stock
  def update_stock
    product = Product.find(self.product_id) || nil

    # If product has been found
    if product
      # If sale is active
      if self.sale.state
        # If sale is a invoice
        if self.sale.status == "invoiced"
          # If sale details has been returned
          if self.status == "returned"

            # If sale details has been invoiced
          else
            old_quantity = self.changes["quantity"][0] if changes["quantity"]
            old_quantity = 0 if !old_quantity

            old_status = self.changes["status"][0] if changes["status"]
            old_status = "invoiced" if !old_status

            # If is a order that is being invoiced
            if self.sale.status == "invoiced" && old_status == "ordered"
              if (product.stock - self.quantity) < 0
                self.errors.add(:quantity, I18n.t("sale.stock_is_less", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
                return

              else
                product.stock = product.stock - self.quantity
              end

              # If already is a invoice
            else
              final_stock = product.stock + old_quantity - self.quantity

              product.stock = final_stock

              returned = SaleDetail.new
              returned.sale_id = self.sale_id
              returned.product_id = self.product_id
              returned.price = self.price
              returned.quantity = self.quantity
              returned.status = "returned"

              if returned.save
                puts "Return created on detail update"
              end
            end
            # End If already is a invoice
          end
          # End If sale details has been invoiced

          # Trigger saving successfully
          if product.save

            # Trigger saving failed
          else
            puts "Product stock not updated"
          end
        end
        # End If sale is a invoice
      end
      # End If sale is active
    end
    # End If product has been found
  end
  # End Update product stock

  # Update product stock on create
  def update_stock_create
    product = Product.find(self.product_id) || nil

    # If product has been found
    if product
      old_quantity = self.changes["quantity"][0] if changes["quantity"]
      old_quantity = 0 if !old_quantity

      old_status = self.changes["status"][0] if changes["status"]
      old_status = "invoiced" if !old_status

      # If is a order that is being invoiced
      if (product.stock - self.quantity) < 0
        self.errors.add(:quantity, I18n.t("sale.stock_is_less_sale", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
        return

      else
        product.stock = product.stock - self.quantity
      end

      # Trigger saving successfully
      if product.save

        # Trigger saving failed
      else
        puts "Product stock not updated"
      end
    end
    # End If product has been found
  end
  # End Update product stock on create

  ## End Callbacks

  # Search orders
  def self.search_orders(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").ordered.not_returned

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).ordered.not_returned

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).ordered.not_returned
    end
  end
  # End Search orders

  # Search invoices
  def self.search_invoices(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").invoiced.not_returned

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).invoiced.not_returned

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).invoiced.not_returned
    end
  end
  # End Search invoices

  # Search shipments
  def self.search_shipments(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%").shipped.not_returned

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id).shipped.not_returned

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).shipped.not_returned
    end
  end
  # End Search shipments

  # Search returns
  def self.search_returns(search)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search)", search: "%#{search}%").returned

    else
      returned
    end
  end
  # End Search returns

  # Search
  def self.search(sale_id, search, show_all)
    if search
      self.joins(:sale).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search OR sale_details.status LIKE :search) AND (sale_details.sale_id = :sale_id)", sale_id: sale_id, search: "%#{search}%")

    elsif show_all == "all"
      self.where("sale_id = :sale_id", sale_id: sale_id)

    else
      self.where("sale_id = :sale_id", sale_id: sale_id).not_returned
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
  validates :price, numericality: {greater_than_or_equal_to: 0}
  validates :quantity, numericality: {greater_than: 0}
  # End Numericality validation

  ## Scopes
  scope :not_returned, -> { where("(sale_details.status != 'returned')") }
  scope :returned, -> { where("(sale_details.status = 'returned')") }
  scope :ordered, -> { where("(sale_details.status = 'ordered')") }
  scope :invoiced, -> { where("(sale_details.status = 'invoiced')") }
  scope :shipped, -> { where("(sale_details.status = 'shipped')") }
  ## End Scopes
end
