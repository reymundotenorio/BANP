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
  before_update :update_stock_update #, on: [ :create, :update ]


  # Before_destroy callback, avoid destroy information
  # def not_permit_destroy
  #   false
  # end

  # Update product stock
  def update_stock_create
    product = Product.find(self.product_id) || nil

    # If product has been found
    if product
      # If purchase is active
      if self.purchase.state
        # If purchase is a reception
        if self.purchase.status == "received"
          # If purchase details has been returned
          if self.status == "returned"
            product.stock = product.stock - self.quantity

            # If purchase details has been received
          else
            product.stock = product.stock + self.quantity
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

  # Update product stock
  def update_stock_update
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
            puts "STATUS"
            puts "ERA: #{self.purchase.status}"
            puts "ES: #{self.purchase.status_was}"
            puts "**********************************************"

            if saved_change_to_status?(from: "ordered", to: "received")
              puts "ENTRO EN SAVED CHANGE"
            end

            if self.purchase.status == "received" && self.purchase.status_was == "ordered"
              puts "ENTRO EN #{1}"
              puts "ERA: #{product.stock}"
              puts "ES: #{product.stock + self.quantity}"
              puts "**********************************************"

              product.stock = product.stock + self.quantity
              # If is a reception
            else
              # If the previous quantity is more than the new quantity
              if self.quantity_was > self.quantity
                # If the stock is less than the new quantity
                if product.stock < self.quantity
                  self.errors.add(:quantity, "Cantidad no debe ser mayor a stock #{product.stock}")
                  return

                  # If the stock is more than the new quantity
                else
                  product.stock = product.stock - self.quantity_was + self.quantity
                end

                # If the previous quantity is less or equal than the new quantity
              else
                product.stock = product.stock - self.quantity_was + self.quantity
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
