class AddMyDairyIdToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :my_dairy_id, :bigint
  end
end
