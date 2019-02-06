class PurchaseDetail < ApplicationRecord
  # Associations
  belongs_to :purchase

  # Audit
  audited associated_with: :purchase
  # End Audit

  # Render sync
  sync :all
  sync_touch :purchase
  # End Render sync
end
