class AddDateColumnToDepositAndProudcts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :date, :date
    add_column :deposit_histories, :date, :date

    # Update products table
    Product.all.each do |product|
      product.update(date: product.created_at.to_date)
    end
    
    # Update deposit_histories table
    DepositHistory.all.each do |deposit_history|
      deposit_history.update(date: deposit_history.created_at.to_date)
    end
  end
end
