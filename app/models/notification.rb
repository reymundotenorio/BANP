class Notification < ApplicationRecord
  # Render sync
  sync :all
  # End Render sync

  # Presence validation
  validates :message, presence: true
  validates :path, presence: true
  # validates :authorized_roles, presence: true
  validates :read_by, presence: true
  #   validates :state, presence: true
  # End  Presence validation

  ## Scopes
  scope :unread, -> { where(read_by: "false") }
  ## End Scopes
end
