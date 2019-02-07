class Purchase < ApplicationRecord
  # Associations
  has_many :purchase_details
  has_one :provider
  has_one :employee
  # End Associations
  
  # Audit
  audited
  audited associated_with: :purchase_details
  # End Audit

  # Render sync
  sync :all
  sync_touch :purchase_details
  # End Render sync
end
