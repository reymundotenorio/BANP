class Employee < ApplicationRecord
  # Associations
  has_one :user
  has_many :purchases
  # End Associations

  # Audit
  has_associated_audits
  audited
  # End Audit

  # Render sync
  sync :all
  sync_touch :purchases
  # End Render sync

  # Execute after record is saved on the Database
  after_save :update_user_email

  # Update the email of the user associated
  def update_user_email
    if self.user.present?
      self.user.update(email: self.email)
    end
  end

  # Search
  def self.search(search, show_all)
    if search
      query = "(first_name LIKE :search OR last_name LIKE :search OR phone LIKE :search OR email LIKE :search)"
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
      [:first_name, :last_name, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || first_name_changed? || last_name_changed?
  end
  # End Update Friendly_ID slug

  ## End Friendly_ID

  # Active Storage
  has_one_attached :image
  # End Active Storage

  ## Validations

  # Uniqueness validation
  validates :email, uniqueness: { case_sensitive: false }
  validates :phone, uniqueness: { case_sensitive: false }
  # End Uniqueness validation

  # Presence validation
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :role, presence: true
  # End  Presence validation

  # Length validation
  validates :first_name, length: { maximum: 255 }
  validates :last_name, length: { maximum: 255 }
  validates :email, length: { maximum: 255 }
  # validates :phone, length: { is: 14 }, allow_blank: true # Avoid phone validation
  validates :role, length: { maximum: 20 }
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

  # User email validation
  validate :user_email

  # Validate that email does not exist in the users records
  def user_email
    if self.user.present?
      user = User.find_by(email: self.email)

      if !user.nil? && user.employee_id != self.id
        errors.add(:email, :blank, message: I18n.t("validates.user_email_taken"))
      end
    end
  end

  # Format validation
  # validates_format_of :phone, with: /\A\(\d{3}\) \d{3}-\d{4}\z/, allow_blank: true # (000) 000-0000 # Avoid phone validation
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

  # Helpers

  # Is administrator?
  # def is_admin?
  #   role == "administrator"
  # end

  # End Helpers

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
