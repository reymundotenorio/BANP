class Sale < ApplicationRecord
  # Associations
  has_many :sale_details
  has_one :customer
  has_one :employee
  # End Associations
  
  # Audit
  audited
  audited associated_with: :sale_details
  # End Audit

  # Render sync
  sync :all
  sync_touch :sale_details
  # End Render sync
end
