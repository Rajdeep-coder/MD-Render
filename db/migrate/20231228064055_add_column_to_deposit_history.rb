class AddColumnToDepositHistory < ActiveRecord::Migration[7.1]
  def change
    add_column :deposit_histories, :quntity, :float
    add_column :deposit_histories, :product_id, :bigint
    add_column :deposit_histories, :deposit_type, :integer

    remove_column :deposit_histories, :product, :string
  end
end
