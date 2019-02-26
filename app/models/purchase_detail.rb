class PurchaseDetail < ApplicationRecord
  # Associations
  belongs_to :purchase
  belongs_to :product
  # End Associations

  # Audit
  audited associated_with: :purchase
  # End Audit

  # Render sync
  sync :all
  # sync_touch :purchase
  # End Render sync

  ## Callbacks

  # Before destroy
  # before_destroy :not_permit_destroy

  # After save and update
  # after_create :update_stock_create #, on: [ :create, :update ]
  # before_save :update_stock #, on: [ :create, :update ]
  before_validation :probando

  def probando
    self.errors.add(:quantity, "Cantidad no debe ser mayor a stock X")
  end

  # Before_destroy callback, avoid destroy information
  # def not_permit_destroy
  #   false
  # end

  # Update product stock
  def update_stock
    product = Product.find(self.product_id) || nil

    # If product has been found
    if product
      # If purchase is active
      if self.purchase.state
        # If purchase is a reception
        if self.purchase.status == "received"
          # If purchase details has been returned
          if self.status == "returned"
            # If the stock is less than the quantity to return
            if product.stock < self.quantity
              self.errors.add(:quantity, "Cantidad no debe ser mayor a stock #{product.stock}")
              return

              # If the stock is greater or equal than the quantity to return
            else
              product.stock = product.stock - self.quantity
            end

            # If purchase details has been received
          else
            # If is a order that is being received
            puts "**********************************************"
            puts "STATUS"
            puts "WAS: #{self.purchase.status_before_last_save}"
            puts "IS: #{self.purchase.status}"
            puts "CHANGES 1: #{self.changes["status"][0]  if self.changes["status"]}"
            puts "CHANGES 1: #{self.changes["status"][1]  if self.changes["status"]}"
            puts "**********************************************"

            puts "**********************************************"
            puts "QUANTITY"
            puts "WAS: #{self.quantity_before_last_save}"
            puts "IS: #{self.quantity}"
            puts "CHANGES 1: #{self.changes["quantity"][0] if self.changes["quantity"]}"
            puts "CHANGES 1: #{self.changes["quantity"][1] if self.changes["quantity"]}"
            puts "**********************************************"

            old_quantity = self.changes["quantity"] ? self.changes["quantity"][0] : 0;
            # new_quantity = self.changes["quantity"] ? self.changes["quantity"][1] : 0;

            if self.purchase.status == "received" && self.purchase.status_before_last_save == "ordered"
              product.stock = product.stock + self.quantity

              # If is a reception
            else
              final_stock = product.stock - old_quantity + self.quantity

              puts "**********************************************"
              puts "STOCK"
              puts "Final stock: #{final_stock}"
              puts "**********************************************"

              # If the new quantity is more than the stock
              if (product.stock - old_quantity + self.quantity) < 0
                puts "ERRORRRR NEGATIVO"
                errors.add(:quantity, "Cantidad no debe ser mayor a stock #{product.stock}")
                return

                # If the new quantity is less than the stock
              else
                product.stock = product.stock - old_quantity + self.quantity
              end
            end
          end

          # Trigger saving successfully
          if product.save
            puts "Product stock UPDATED"

            # Trigger saving failed
          else
            puts "Product stock NOT UPDATED"
          end
        end
        # End If purchase is a reception
      end
      # End If purchase is active
    end
  end
  # End Update product stock

  ## End Callbacks

  # Search orders
  def self.search_orders(purchase_id, search, show_all)
    if search
      self.joins(:purchase).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (purchase_details.purchase_id = :purchase_id)", purchase_id: purchase_id, search: "%#{search}%").ordered.not_returned

    elsif show_all == "all"
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).ordered.not_returned

    else
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).ordered.not_returned
    end
  end
  # End Search orders

  # Search receptions
  def self.search_receptions(purchase_id, search, show_all)
    if search
      self.joins(:purchase).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search) AND (purchase_details.purchase_id = :purchase_id)", purchase_id: purchase_id, search: "%#{search}%").received.not_returned

    elsif show_all == "all"
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).received.not_returned

    else
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).received.not_returned
    end
  end
  # End Search receptions

  # Search
  def self.search(purchase_id, search, show_all)
    if search
      self.joins(:purchase).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search OR purchase_details.status LIKE :search) AND (purchase_details.purchase_id = :purchase_id)", purchase_id: purchase_id, search: "%#{search}%")

    elsif show_all == "all"
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id)

    else
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).not_returned
    end
  end
  # End Search

  # extend FriendlyId
  # friendly_id :slug_candidates, use: :slugged
  #
  # # Friendly_ID slug_candidates
  # def slug_candidates
  #   [
  #     [:purchase_id, :id]
  #   ]
  # end
  #
  # # Update Friendly_ID slug
  # def should_generate_new_friendly_id?
  #   slug.blank? || purchase_id_changed?
  # end
  # # End Update Friendly_ID slug

  # Presence validation
  # validates :purchase_id, presence: true
  validates :product_id, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  # End  Presence validation

  # Length validation
  validates :status, length: { maximum: 255 }
  # End Length validation

  ## Scopes
  scope :not_returned, -> { where("(purchase_details.status != 'returned')") }
  scope :returned, -> { where("(purchase_details.status = 'returned')") }
  scope :ordered, -> { where("(purchase_details.status = 'ordered')") }
  scope :received, -> { where("(purchase_details.status = 'received')") }
  ## End Scopes

end
