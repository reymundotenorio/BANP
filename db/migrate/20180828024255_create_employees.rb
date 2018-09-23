class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      # Information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, limit: 14 # Phone number format (000) 000-0000
      t.string :role, null: false #
      t.boolean :confirmed, default: false, null: false
      t.boolean :state, default: true, null: false

      t.attachment :image # Paperclip file_name, content_type, file_size, updated_at
      t.string :slug, unique: true # Friendly_id slug

      # Authenticatable
      # t.string :email, null: false
      t.string :password_digest, null: false # Encrypted password

      # Recoverable
      t.string :reset_password_token
      t.boolean :reset_password_sent, default: false, null: false

      # Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # Confirmable
      t.string :confirmation_token
      t.boolean :confirmation_sent, default: false, null: false

      # Lockable
      t.integer :failed_attempts, default: 0, null: false
      t.string :unlock_token # Unlock by email or text code
      t.boolean :unlock_sent, default: false, null: false

      t.timestamps
    end

    add_index :employees, :email, unique: true
    add_index :employees, :reset_password_token, unique: true
    add_index :employees, :confirmation_token, unique: true
    add_index :employees, :unlock_token, unique: true
  end
end
