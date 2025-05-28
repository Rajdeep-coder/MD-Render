class AddStockQuantityToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :stock_quantity, :decimal, precision: 10, scale: 2, default: 0.0
  end
end
