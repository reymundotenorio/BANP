class PurchaseDetail < ApplicationRecord
  # Associations
  belongs_to :purchase
  belongs_to :product
  # End Associations

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  # sync_touch :purchase
  # End Render sync

  ## Callbacks

  # Before destroy
  # before_destroy :not_permit_destroy

  # After save and update
  after_save :update_stock #, on: [ :create, :update ]

  # Before_destroy callback, avoid destroy information
  def not_permit_destroy
    false
  end

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

  ## End Callbacks

  # Search orders
  def self.search_orders(purchase_id, search, show_all)
    if search
      self.joins(:purchase).joins(:product).where("(products.name LIKE :search OR products.name_spanish LIKE :search OR purchase_details.status LIKE :search) AND (purchase_details.purchase_id = :purchase_id)", purchase_id: purchase_id, search: "%#{search}%").not_returned

    elsif show_all == "all"
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).not_returned

    else
      self.where("purchase_id = :purchase_id", purchase_id: purchase_id).not_returned
    end
  end
  # End Search orders

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

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Friendly_ID slug_candidates
  def slug_candidates
    [
      [:purchase_id, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || purchase_id_changed?
  end
  # End Update Friendly_ID slug

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
  ## End Scopes

end
