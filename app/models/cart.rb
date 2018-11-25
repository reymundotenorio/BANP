class Cart < ApplicationRecord
  # Associations
  has_many :cart_details
  belongs_to :costumer

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  sync_touch :cart_details
  # End Render sync

  ## Validations

  # Uniqueness validation
  validates :id_costumer, uniqueness: { case_sensitive: true }
  # End Uniqueness validation

  # Presence validation
  validates :id_costumer, presence: true
  # End  Presence validation

  ## End Validations

  ## Callbacks

  # Before destroy
  before_destroy :not_permit_destroy

  # Before_destroy callback, avoid destroy information
  def not_permit_destroy
    false
  end

  ## End Callbacks
end
