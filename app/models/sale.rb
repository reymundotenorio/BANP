class Sale < ApplicationRecord
  # Associations
  has_many :sale_details
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
end