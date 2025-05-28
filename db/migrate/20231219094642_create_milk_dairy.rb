class CreateMilkDairy < ActiveRecord::Migration[7.1]
  def change
    create_table :my_dairies do |t|
      t.string :dairy_name
      t.string :owner_name
      t.string :phone_number
      t.string :email
      t.string :password_digest
      t.timestamps
      # t.boolean :avalibilty , default: false
      # t.datetime :start_time
      # t.datetime :end_time
      # t.integer :shift
    end
  end
end
