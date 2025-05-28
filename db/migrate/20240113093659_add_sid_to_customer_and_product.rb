class AddSidToCustomerAndProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :sid, :bigint
    add_column :products, :sid, :bigint
  end
end
