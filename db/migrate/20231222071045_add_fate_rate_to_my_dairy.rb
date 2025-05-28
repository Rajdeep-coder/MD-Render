class AddFateRateToMyDairy < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :fate_rate, :float
  end
end
