class CreateRecharg < ActiveRecord::Migration[7.1]
  def change
    create_table :rechargs do |t|
      t.bigint :my_dairy_id 
      t.bigint :plan_id 
      t.integer :activated, default:0
      t.date :expire_date
      t.float :amount
      t.timestamps
    end
  end
end
