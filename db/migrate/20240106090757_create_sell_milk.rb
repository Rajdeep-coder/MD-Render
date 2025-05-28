class CreateSellMilk < ActiveRecord::Migration[7.1]
  def change
    create_table :sell_milks do |t|
      t.bigint :my_dairy_id
      t.float :avg_fat
      t.float :avg_clr
      t.float :avg_snf
      t.float :total_quntity
      t.float :total_amount
      t.float :fat
      t.float :clr
      t.float :snf
      t.float :quntity
      t.float :amount
      t.float :benifit
      t.float :weight_lose
      t.integer :shift
      t.date :date 
      t.timestamps
    end
  end
end
