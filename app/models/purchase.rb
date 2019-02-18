class Purchase < ApplicationRecord
  # Associations
  has_many :purchase_details, inverse_of: :purchase
  belongs_to :provider
  belongs_to :employee
  # End Associations

  # Nested attributes
  accepts_nested_attributes_for :purchase_details
  # End Nested attributes

  # Audit
  audited
  audited associated_with: :purchase_details
  # End Audit

  # Render sync
  sync :all
  sync_touch :purchase_details
  # End Render sync

  # Search
  def self.search_order(search, show_all)
    if search
      self.joins(:provider).joins(:employee).where("(DATE_FORMAT(purchase_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(purchase_datetime, '%m/%d/%Y') LIKE :search OR receipt_number LIKE :search OR providers.name LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'ordered')", search: "%#{search}%")

    elsif show_all == "all"
      orders

    else
      orders.enabled
    end
  end
  # End Search

  # Total
  def self.total(id)
    self.find(id).purchase_details.not_returned.sum("price * quantity")
  end
  # End Total

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Friendly_ID slug_candidates
  def slug_candidates
    [
      [:receipt_number],
      [:receipt_number, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || receipt_number_changed?
  end
  # End Update Friendly_ID slug

  ## End Friendly_ID

  # Presence validation
  validates :receipt_number, presence: true
  validates :provider_id, presence: true
  validates :employee_id, presence: true
  # End  Presence validation

  # Length validation
  validates :receipt_number, length: { maximum: 255 }
  validates :status, length: { maximum: 255 }
  validates :observations, length: { maximum: 255 }, allow_blank: true
  # End Length validation

  ## Scopes
  scope :enabled, -> { where(state: true) }
  scope :orders, -> { where(status: "ordered") }
  ## End Scopes

  ## Callbacks

  # Before destroy
  before_destroy :not_permit_destroy

  # Before_destroy callback, avoid destroy information
  def not_permit_destroy
    false
  end

  ## End Callbacks
end
