class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :slug # Friendly_id slug

      # t.references :costumber, foreign_key: true

      # Authenticatable
      t.string :password_digest, null: false # Encrypted password

      # Recoverable
      t.string :reset_password_token
      t.boolean :reset_password_sent, null: false, default: false
      t.datetime :reset_password_sent_at

      # Trackable
      t.integer :sign_in_count, null: false, default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      # Confirmable
      t.boolean :confirmed, null: false, default: false
      t.string :confirmation_token
      t.boolean :confirmation_sent, null: false, default: false

      # Lockable
      t.integer :failed_attempts, null: false, default: 0
      t.string :unlock_token # Unlock by email or text code
      t.boolean :unlock_sent, null: false, default: false

      # Two factor authentication
      t.boolean :two_factor_auth, null:false, default: false
      t.string :two_factor_auth_otp, unique: true

      t.timestamps # create_at & update_at
    end

    add_reference :users, :employee, index: true, foreign_key: true
    add_reference :users, :customer, index: true, foreign_key: true

    add_index :users, :email, unique: true
    add_index :users, :slug, unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token, unique: true
    add_index :users, :unlock_token, unique: true
    # add_index :users, :two_factor_auth_otp, unique: true
  end
end
