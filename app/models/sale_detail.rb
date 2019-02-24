class SaleDetail < ApplicationRecord
  # Associations
  belongs_to :sale
  belongs_to :product
  # End Associations

  # Nested attributes
  accepts_nested_attributes_for :sale
  # End Nested attributes

  # Audit
  audited
  audited associated_with: :sale
  # End Audit

  # Render sync
  sync :all
  # sync_touch :sale
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
