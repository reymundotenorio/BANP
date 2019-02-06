class Purchase < ApplicationRecord
  # Association
  has_many :purchase_details

  # Nested attributes
  accepts_nested_attributes_for :purchase_details

  # Audit
  has_associated_audits
  audited
  # End Audit

  # Render sync
  sync :all
  # End Render sync
end
