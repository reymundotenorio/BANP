class User < ApplicationRecord
  # Secure password
  has_secure_password validations: false

  # Associations
  belongs_to :employee, optional: true
  belongs_to :customer, optional: true

  # Audit
  audited associated_with: :employee
  audited associated_with: :customer
  # End Audit

  # Render sync
  sync :all
  sync_touch :employee, :customer
  # End Render sync

  ## Friendly_ID

  extend FriendlyId
  friendly_id :slug_candidates, use: :slugged

  # Friendly_ID slug_candidates
  def slug_candidates
    [
      [:email],
      [:email, :id]
    ]
  end

  # Update Friendly_ID slug
  def should_generate_new_friendly_id?
    slug.blank? || email_changed?
  end
  # End Update Friendly_ID slug

  ## End Friendly_ID

  ## Validations

  # Uniqueness validation
  validates :email, uniqueness: { case_sensitive: false }
  # End Uniqueness validation

  # Confirmation validation
  validates :password, confirmation: true, if: :password_present?
  # End Confirmation validation

  def password_present?
    new_record? || password.present? && password_confirmation.present?
  end

  # Presence validation
  validates :email, presence: true
  validates :password, presence: true, if: :password_present?
  validates :password_confirmation, presence: true, if: :password_present?
  # End  Presence validation

  # Length validation
  validates :email, length: { maximum: 255 }
  validates :password, length: { minimum: 8 }, if: :password_present?
  validates :two_factor_auth_otp, length: { is: 6 }, allow_blank: true # Avoid OTP validation
  # End Length validation

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
