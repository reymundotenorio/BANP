class Employee < ApplicationRecord
  # Secure password
  # has_secure_password validations: false

  # Search
  def self.search(search, show_all)
    if search
      query = "(first_name LIKE :search OR last_name LIKE :search OR phone LIKE :search OR email LIKE :search OR role LIKE :search)"
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
      [:first_name, :last_name],
      [:first_name, :last_name, :id],
      [:first_name, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || first_name_changed? || last_name_changed?
  end
  # End Update Friendly_ID slug

  ## End Friendly_ID


  ## Validations

  # Uniqueness validation
  validates :email, uniqueness: { case_sensitive: false }
  validates :phone, uniqueness: { case_sensitive: false }
  # End Uniqueness validation

  # Confirmation validation
  # validates :password, confirmation: true, if: :password_present?
  # End Confirmation validation

  # def password_present?
  #   new_record? || password.present? && password_confirmation.present?
  # end

  # Presence validation
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  # validates :password, presence: true, if: :password_present?
  # validates :password_confirmation, presence: true, if: :password_present?
  validates :role, presence: true
  # End  Presence validation

  # Length validation
  validates :first_name, length: { maximum: 255 }
  validates :last_name, length: { maximum: 255 }
  validates :phone, length: { is: 14 }, allow_blank: true
  validates :email, length: { maximum: 255 }
  # validates :password, length: { minimum: 8 }, if: :password_present?
  validates :role, length: { maximum: 20 }
  # End Length validation

  # Format validation
  validates_format_of :phone, with: /\A\(\d{3}\) \d{3}-\d{4}\z/, allow_blank: true # (000) 000-0000
  # End Format validation

  # Validate employee role
  # validate :employee_role

  # Employee role
  # def employee_role
  #   if role != 0 && role != 1 && role != 2
  #     errors.add(:role, "Must select the employee role")
  #   end
  # end

  ## End Validations


  ## Paperclip

  # Image validation (whiny = silence ImageMagick Error)
  has_attached_file :image,
  whiny: false,
  styles: { thumb: "100x100>", medium: "300x300>", regular: "800x800>" },
  default_url: "https://s3.amazonaws.com/betterandnice/images/default/default.png",
  url: "/images/employees/:id/:style/:basename.:extension",
  path: ":rails_root/public/images/employees/:id/:style/:basename.:extension"

  validates_attachment_content_type :image,
  content_type: ["image/jpeg", "image/gif", "image/png"],
  message: I18n.t("validates.image_format")

  validates_attachment_size :image,
  less_than: 5.megabytes,
  message: I18n.t("validates.image_size")

  ## End Paperclip

  ## Scopes
  scope :enabled, -> { where(state: true) }
  ## End Scopes

  # Audit
  audited
  # End Audit

  # Render sync
  sync :all
  # End Render sync

  ## Callbacks

  # Before destroy
  before_destroy :not_permit_destroy

  # Before_destroy callback, avoid destroy information
  def not_permit_destroy
    false
  end

  ## End Callbacks

end
