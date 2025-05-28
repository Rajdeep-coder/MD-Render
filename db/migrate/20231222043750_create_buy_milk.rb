class CreateBuyMilk < ActiveRecord::Migration[7.1]
  def change
    create_table :buy_milks do |t|
      t.float :fat , default:0
      t.float :clr , default:0
      t.float :snf , default:0
      t.float :quntity
      t.float :amount
      t.bigint :customer_id
      t.timestamps
    end
  end
end
