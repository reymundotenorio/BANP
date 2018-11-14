class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.string :name, null: false
      t.string :FEIN, limit: 10 # Federal Employer Identification Number (FEIN) format 00-0000000
      t.string :email
      t.string :phone, limit: 14 # Phone number format (000) 000-0000
      t.string :address
      t.boolean :state, default: true, null: false
      
      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end
    
    add_index :providers, :FEIN, unique: true
    add_index :providers, :email, unique: true
    add_index :providers, :phone, unique: true
    add_index :providers, :slug, unique: true
  end
end
