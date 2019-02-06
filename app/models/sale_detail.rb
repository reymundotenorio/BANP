class SaleDetail < ApplicationRecord
  # Associations
  belongs_to :sale

  # Audit
  audited associated_with: :sale
  # End Audit

  # Render sync
  sync :all
  sync_touch :sale
  # End Render sync
end
