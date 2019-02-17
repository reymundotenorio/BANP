class Sale < ApplicationRecord
  # Associations
  has_many :sale_details, inverse_of: :sale
  belongs_to :customer
  belongs_to :employee
  # End Associations

  # Audit
  audited
  audited associated_with: :sale_details
  # End Audit

  # Render sync
  sync :all
  sync_touch :sale_details
  # End Render sync

  ## Callbacks

  # Before destroy
  before_destroy :not_permit_destroy

  # Before_destroy callback, avoid destroy information
  def not_permit_destroy
    false
  end

  ## End Callbacks
end
