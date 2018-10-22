class User < ApplicationRecord
  # Associations
  belongs_to :employee, inverse_of: :user, optional: true, foreign_key: email
  # belongs_to :costumer, optional: true

  validates :email, uniqueness: true

  # Secure password
  has_secure_password validations: false

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
