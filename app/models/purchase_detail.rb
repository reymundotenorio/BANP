class PurchaseDetail < ApplicationRecord
  # Associations
  belongs_to :product
  belongs_to :purchase
  # End Associations

  # Nested attributes
  accepts_nested_attributes_for :purchase
  # End Nested attributes

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  sync_touch :product
  sync_touch :purchase
  # End Render sync
end
