class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :name_spanish, null: false
      t.string :description
      t.string :description_spanish
      t.boolean :state, default: true, null: false

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    add_index :categories, :name, unique: true
    add_index :categories, :name_spanish, unique: true
  end
end
