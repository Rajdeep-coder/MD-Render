class CreateCustomerAccount < ActiveRecord::Migration[7.1]
  def change
    create_table :customer_accounts do |t|
      t.float :credit
      t.float :deposit 
      t.float :balance
      t.bigint :customer_id
      t.timestamps
    end
  end
end
