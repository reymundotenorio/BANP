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

  # Search order e-commerce
  def self.search_order_ecommerce(search, customer_id)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR payment_method LIKE :search OR payment_reference LIKE :search OR delivery_status LIKE :search) AND (status != 'invoiced') AND (sales.customer_id = :customer_id)", customer_id: customer_id, search: "%#{search}%").order("sales.sale_datetime DESC")

    else
      self.where("sales.customer_id = :customer_id", customer_id: customer_id).not_invoices.order("sales.sale_datetime DESC")
    end
  end
  # End Search order e-commerce

  # Search order
  def self.search_order(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.first_name LIKE :search OR customers.last_name LIKE :search OR customers.company LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'ordered')", search: "%#{search}%").order("sales.sale_datetime DESC")

    elsif show_all == "all"
      orders.order("sales.sale_datetime DESC")

    else
      orders.enabled.order("sales.sale_datetime DESC")
    end
  end
  # End Search order

  # Search invoice
  def self.search_invoice(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.first_name LIKE :search OR customers.last_name LIKE :search OR customers.company LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'invoiced')", search: "%#{search}%").order("sales.sale_datetime DESC")

    elsif show_all == "all"
      invoices.order("sales.sale_datetime DESC")

    else
      invoices.enabled.order("sales.sale_datetime DESC")
    end
  end
  # End Search invoice

  # Search shipment
  def self.search_shipment(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.first_name LIKE :search OR customers.last_name LIKE :search OR customers.company LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'shipped')", search: "%#{search}%").order("sales.sale_datetime DESC")

    elsif show_all == "all"
      shipments.order("sales.sale_datetime DESC")

    else
      shipments.enabled.order("sales.sale_datetime DESC")
    end
  end
  # End Search shipment

  # Search delivery
  def self.search_delivery(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.first_name LIKE :search OR customers.last_name LIKE :search OR customers.company LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'delivered')", search: "%#{search}%").order("sales.sale_datetime DESC")

    elsif show_all == "all"
      deliveries.order("sales.sale_datetime DESC")

    else
      deliveries.enabled.order("sales.sale_datetime DESC")
    end
  end
  # End Search delivery

  # Search price list
  def self.search_price_list(search, show_all)
    if search
      self.joins(:customer).joins(:employee).where("(DATE_FORMAT(sale_datetime, '%d/%m/%Y') LIKE :search OR DATE_FORMAT(sale_datetime, '%m/%d/%Y') LIKE :search OR customers.first_name LIKE :search OR customers.last_name LIKE :search OR customers.company LIKE :search OR employees.first_name LIKE :search OR employees.last_name LIKE :search) AND (status = 'price_list')", search: "%#{search}%").order("sales.sale_datetime DESC")

    else
      price_lists.order("sales.sale_datetime DESC")
    end
  end
  # End Search price list

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
  # validates :discount, numericality: {greater_than_or_equal_to: 0, less_than: 100}
  # End Numericality validation

  ## Scopes
  scope :not_invoices, -> { where("(sales.status != 'invoiced')") }
  scope :enabled, -> { where(state: true) }
  scope :orders, -> { where(status: "ordered") }
  scope :invoices, -> { where(status: "invoiced") }
  scope :shipments, -> { where(status: "shipped") }
  scope :deliveries, -> { where(status: "delivered") }
  scope :price_lists, -> { where(status: "price_list") }
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
