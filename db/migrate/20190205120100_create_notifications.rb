class CreateNotifications < ActiveRecord::Migration[5.2]
  def change
    create_table :notifications do |t|
      t.string :message, null: false
      t.string :path
      t.string :authorized_roles
      t.text :read_by
      t.boolean :state, null: false, default: true
      # t.string :slug # Friendly_id slug
      t.timestamps # create_at & update_at
    end

    # add_index :notifications, :slug, unique: true
  end
end
