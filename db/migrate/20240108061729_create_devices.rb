class CreateDevices < ActiveRecord::Migration[7.1]
  def change
    create_table :devices do |t|
      t.string :name
      t.text :token
      t.integer :token_type
      t.bigint :my_dairy_id
      t.bigint :customer_id

      t.timestamps
    end
  end
end
