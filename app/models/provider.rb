class Provider < ApplicationRecord
  # Associations
  has_many :purchases
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
        self.where("(name LIKE :search OR FEIN LIKE :search OR phone LIKE :search OR email LIKE :search OR address LIKE :search) AND (state = true)", search: "%#{search}%")

      else
        self.where("(name LIKE :search OR FEIN LIKE :search OR phone LIKE :search OR email LIKE :search OR address LIKE :search)", search: "%#{search}%")
      end

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
      [:name, :FEIN, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || name_changed? || FEIN_changed?
  end
  # End Update Friendly_ID slug

  ## End Friendly_ID

  # Active Storage
  has_one_attached :image
  # End Active Storage

  ## Validations

  # Uniqueness validation
  validates :FEIN, uniqueness: { case_sensitive: false }
  validates :email, uniqueness: { case_sensitive: false }
  validates :phone, uniqueness: { case_sensitive: false }
  # End Uniqueness validation

  # Presence validation
  validates :name, presence: true
  # End  Presence validation

  # Length validation
  validates :name, length: { maximum: 255 }
  validates :FEIN, length: { is: 10 }, allow_blank: true
  validates :email, length: { maximum: 255 }, allow_blank: true
  #   validates :phone, length: { is: 14 }, allow_blank: true
  validates :address, length: { maximum: 255 }, allow_blank: true
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

  # Format validation
  validates_format_of :FEIN, with: /\A\d{2}-\d{7}\z/ ,allow_blank: true # 00-0000000
  #   validates_format_of :phone, with: /\A\(\d{3}\) \d{3}-\d{4}\z/ ,allow_blank: true # (000) 000-0000
  # End Format validation

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
