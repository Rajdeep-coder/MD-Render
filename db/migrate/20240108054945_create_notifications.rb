class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :title
      t.text :body
      t.string :notify_type
      t.integer :customer_id
      t.integer :my_dairy_id
      t.boolean :is_read, default: false

      t.timestamps
    end
  end
end
