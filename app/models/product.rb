class Product < ApplicationRecord
  # Associations
  belongs_to :category
  has_many :purchase_details
  has_many :sale_details
  # End Associations

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  # End Render sync

  # Search
  def self.search(search, show_all)
    if search
      if show_all == "enabled-only"
        self.joins(:category).where("(products.name LIKE :search OR products.name_spanish LIKE :search OR categories.name LIKE :search OR categories.name_spanish LIKE :search OR barcode LIKE :search OR products.description LIKE :search OR products.description_spanish LIKE :search) AND (products.state = true)", search: "%#{search}%")

      else
        self.joins(:category).where("products.name LIKE :search OR products.name_spanish LIKE :search OR categories.name LIKE :search OR categories.name_spanish LIKE :search OR barcode LIKE :search OR products.description LIKE :search OR products.description_spanish LIKE :search", search: "%#{search}%")
      end
    elsif show_all == "all"
      all

    else
      enabled
    end
  end
  # End Search

  def self.find_category(category_slug)
    Product.joins(:category).where(categories: { slug: category_slug }).group(:id)
  end

  ## Friendly_ID

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Friendly_ID slug_candidates
  def slug_candidates
    [
      [:name],
      [:name, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
  # End Update Friendly_ID slug

  ## End Friendly_ID

  # Active Storage
  has_one_attached :image
  # End Active Storage

  ## Validations

  # Uniqueness validation
  validates :name, uniqueness: { case_sensitive: false }
  validates :name_spanish, uniqueness: { case_sensitive: false }
  validates :barcode, uniqueness: { case_sensitive: false }
  # End Uniqueness validation

  # Presence validation
  validates :name, presence: true
  validates :name_spanish, presence: true
  validates :barcode, presence: true
  validates :price, presence: true
  # validates :stock, presence: true
  # End  Presence validation

  # Length validation
  validates :name, length: { maximum: 255 }
  validates :name_spanish, length: { maximum: 255 }
  validates :barcode, length: { maximum: 255 }
  validates :content, length: { maximum: 255 }, allow_blank: true
  validates :content_spanish, length: { maximum: 255 }, allow_blank: true
  validates :description, length: { maximum: 255 }, allow_blank: true
  validates :description_spanish, length: { maximum: 255 }, allow_blank: true
  validates :recipes, length: { maximum: 255 }, allow_blank: true
  validates :recipes_spanish, length: { maximum: 255 }, allow_blank: true
  # End Length validation

  # Numericality validation
  validates :price, numericality: {greater_than: 0}
  # End Numericality validation

  # Type validation
  validate :correct_image_type
  # End Type validation

  # Validate file type
  def correct_image_type
    if image.attached? && !image.content_type.in?(%w(image/jpeg image/gif image/png))
      errors.add(:image, :blank, message: I18n.t("validates.image_format"))
    end
  end

  ## End Validations

  ## Scopes
  scope :enabled, -> { where(state: true) }
  ## End Scopes

  ## Callbacks

  # Before destroy
  before_destroy :not_permit_destroy

  # Before_destroy callback, avoid destroy information
  def not_permit_destroy
    false
  end

  ## End Callbacks
end
