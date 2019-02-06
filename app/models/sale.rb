class Sale < ApplicationRecord
  # Association
  has_many :sale_details

  # Nested attributes
  accepts_nested_attributes_for :sale_details

  # Audit
  has_associated_audits
  audited
  # End Audit

  # Render sync
  sync :all
  # End Render sync
end
