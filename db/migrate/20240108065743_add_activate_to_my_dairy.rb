class AddActivateToMyDairy < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :plan_id, :bigint  
  end
end
