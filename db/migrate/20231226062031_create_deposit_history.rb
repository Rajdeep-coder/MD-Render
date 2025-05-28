class CreateDepositHistory < ActiveRecord::Migration[7.1]
  def change
    create_table :deposit_histories do |t|
      t.string :product
      t.float :amount
      t.bigint :customer_id
      t.timestamps
    end
  end
end
