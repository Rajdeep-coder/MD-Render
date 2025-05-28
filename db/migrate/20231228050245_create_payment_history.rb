class CreatePaymentHistory < ActiveRecord::Migration[7.1]
  def change
    create_table :payment_histories do |t|
      t.integer :status
      t.float :amount
      t.bigint :customer_id
      t.timestamps
    end
  end
end
