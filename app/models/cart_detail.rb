class CartDetail < ApplicationRecord
  # Associations
  belongs_to :cart

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  # End Render sync

  ## Validations

  # Uniqueness validation
  # validates :id_cart, uniqueness: { case_sensitive: true }
  # validates :id_product, uniqueness: { case_sensitive: true }
  # End Uniqueness validation

  # Presence validation
  validates :id_cart, presence: true
  validates :id_product, presence: true
  validates :quantity, presence: true
  # End  Presence validation

  ## End Validations

  ## Scopes
  scope :enabled, -> { where(state: true) }
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
