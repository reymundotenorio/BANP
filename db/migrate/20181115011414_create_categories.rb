class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :name, null: false, unique: true
      t.string :name_spanish, null: false, unique: true
      t.string :description
      t.string :description_spanish
      t.boolean :state, null: false, default: true

      t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    # add_index :categories, :name, unique: true
    # add_index :categories, :name_spanish, unique: true
    add_index :categories, :slug, unique: true
  end
end
