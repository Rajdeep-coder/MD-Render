class AddLastLowStockThresholdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :last_low_stock_threshold, :integer
  end
end
