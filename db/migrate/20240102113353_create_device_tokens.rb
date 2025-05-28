class CreateDeviceTokens < ActiveRecord::Migration[7.1]
  def change
    create_table :device_tokens do |t|
      t.string :device_token
      t.integer :my_dairy_id
      t.integer :customer_id

      t.timestamps
    end
  end
end
