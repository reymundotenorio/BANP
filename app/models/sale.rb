class Sale < ApplicationRecord
  # Associations
  belongs_to :customer
  belongs_to :employee
  has_many :sale_details, inverse_of: :sale
  # End Associations

  # Nested attributes
  accepts_nested_attributes_for :sale_details, reject_if: :all_blank, allow_destroy: true
  # End Nested attributes

  # Audit
  has_associated_audits
  audited
  # End Audit

  # Render sync
  sync :all
  # sync_touch :sale_details
  # End Render sync

  # Search order
  def self.search_order(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.name LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'ordered')", search: "%#{search}%")

    elsif show_all == "all"
      orders

    else
      orders.enabled
    end
  end
  # End Search order

  # Search invoice
  def self.search_invoice(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.name LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'received')", search: "%#{search}%")

    elsif show_all == "all"
      invoices

    else
      invoices.enabled
    end
  end
  # End Search invoice

  # Search shipment
  def self.search_shipment(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.name LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'shipped')", search: "%#{search}%")

    elsif show_all == "all"
      shipments

    else
      shipments.enabled
    end
  end
  # End Search shipment

  # Total
  def self.total(id)
    self.find(id).sale_details.not_returned.sum("price * quantity")
  end
  # End Total

  # Presence validation
  validates :customer_id, presence: true
  validates :employee_id, presence: true
  validates :sale_datetime, presence: true
  validates :discount, presence: true
  validates :payment_method, presence: true
  validates :payment_reference, presence: true
  # validates :paid, presence: true
  # End  Presence validation

  # Length validation
  validates :delivery_status, length: { maximum: 255 }
  validates :status, length: { maximum: 255 }
  validates :payment_method, length: { maximum: 255 }
  validates :payment_reference, length: { maximum: 255 }
  validates :observations, length: { maximum: 255 }, allow_blank: true
  # End Length validation

  # Numericality validation
  validates :discount, numericality: {greater_than_or_equal_to: 0, less_than: 100}
  # End Numericality validation

  ## Scopes
  scope :enabled, -> { where(state: true) }
  scope :orders, -> { where(status: "ordered") }
  scope :invoices, -> { where(status: "invoiced") }
  scope :shipments, -> { where(status: "shipped") }
  ## End Scopes

  ## Callbacks

  # # Before destroy
  # before_destroy :not_permit_destroy
  #
  # # Before_destroy callback, avoid destroy information
  # def not_permit_destroy
  #   false
  # end

  ## End Callbacks
end
