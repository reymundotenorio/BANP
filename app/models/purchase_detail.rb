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

  before_validation :update_stock, on: :update

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
            # # If the stock is less than the quantity to return
            # if product.stock < self.quantity
            #   self.errors.add(:quantity, "Cantidad no debe ser mayor a stock #{product.stock}")
            #   return false
            #
            #   # If the stock is greater or equal than the quantity to return
            # else
            #   product.stock = product.stock - self.quantity
            # end
            # # End If the stock is less than the quantity to return

            # If purchase details has been received
          else
            old_quantity = self.changes["quantity"][0] if changes["quantity"]
            old_quantity = 0 if !old_quantity

            old_status = self.changes["status"][0] if changes["status"]
            old_status = "received" if !old_status


            # If is a order that is being received
            if self.purchase.status == "received" && old_status == "ordered"
              product.stock = product.stock + self.quantity

              # If already is a reception
            else
              final_stock = product.stock - old_quantity + self.quantity

              # If the new quantity is more than the stock
              if (final_stock) < 0
                self.errors.add(:quantity, I18n.t("purchase.stock_is_less", stock: product.stock, product: I18n.locale == :es ? product.name_spanish : product.name))
                return

                # If the new quantity is less than the stock
              else
                product.stock = final_stock

                # If quantity was reduced
                if self.quantity < old_quantity
                  returned = PurchaseDetail.new
                  returned.purchase_id = self.purchase_id
                  returned.product_id = self.product_id
                  returned.price = self.price
                  returned.quantity = (old_quantity - self.quantity)
                  returned.status = "returned"

                  if returned.save
                    puts "Return created on detail update"
                  end
                end
                # End If quantity was reduced
              end
            end
            # End If already is a reception
          end
          # End If purchase details has been received

          # Trigger saving successfully
          if product.save

            # Trigger saving failed
          else
            puts "Product stock not updated"
          end
        end
        # End If purchase is a reception
      end
      # End If purchase is active
    end
    # End If product has been found
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


  # Search returns
  def self.search_returns(search)
    if search
      self.joins(:purchase).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search)", search: "%#{search}%").returned

    else
      returned
    end
  end
  # End Search returns

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
