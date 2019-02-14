class PurchaseDetail < ApplicationRecord
  # Associations
  belongs_to :purchase
  belongs_to :product
  # End Associations

  # Nested attributes
  accepts_nested_attributes_for :purchase
  # End Nested attributes

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  sync_touch :purchase
  sync_touch :product
  # End Render sync

  # Search
  def self.search_order(purchase_id, search, show_all)
    if search
      self.joins(:purchase).joins(:product).where("(status LIKE :search OR name name :search OR name_spanish LIKE :search) AND (purchase_id = :purchase_id)", search: "%#{search}%", purchase_id: "%#{purchase_id}%")

    elsif show_all == "all"
      query = "purchase_id = :purchase_id"
      where(query, purchase_id: "%#{purchase_id}%")

    else
      enabled
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
  validates :purchase_id, presence: true
  validates :product_id, presence: true
  validates :price, presence: true
  validates :quantity, presence: true
  validates :stock, presence: true
  # End  Presence validation

  # Length validation
  validates :status, length: { maximum: 255 }
  # End Length validation

  ## Scopes
  scope :enabled, -> { where(state: true) }
  scope :returned, -> { where(status: "returned") }
  ## End Scopes


end
