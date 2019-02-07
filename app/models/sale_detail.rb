class SaleDetail < ApplicationRecord
  # Associations
  has_one :product
  belongs_to :sale
  # End Associations
  
  # Nested attributes
  accepts_nested_attributes_for :sale 
  # End Nested attributes

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  sync_touch :product
  sync_touch :sale
  # End Render sync
end
