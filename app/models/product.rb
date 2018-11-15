class Product < ApplicationRecord
  # Associations
  belongs_to :category

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  # End Render sync

  # Search
  def self.search(search, show_all)
    if search
      query = "(name LIKE :search OR description LIKE :search)"
      where(query, search: "%#{search}%")

    elsif show_all == "all"
      all

    else
      enabled
    end
  end
  # End Search

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
  # End Uniqueness validation

  # Presence validation
  validates :name, presence: true
  # End  Presence validation

  # Length validation
  validates :name, length: { maximum: 255 }
  validates :description, length: { maximum: 255 }, allow_blank: true
  # End Length validation

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
