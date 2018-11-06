class CreateEmployees < ActiveRecord::Migration[5.2]
  def change
    create_table :employees do |t|
      # Information
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone, limit: 14 # Phone number format (000) 000-0000
      t.string :role, null: false
      t.boolean :state, default: true, null: false

      # t.attachment :image # Paperclip file_name, content_type, file_size, updated_at
      t.string :slug, unique: true # Friendly_id slug

      t.timestamps
    end

    add_index :employees, :email, unique: true
  end
end
