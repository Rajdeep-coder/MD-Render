class AddLastAssignedSidToMyDairies < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :last_assigned_sid, :integer, default: 0
    MyDairy.find_each do |my_dairy|
      customer_count = my_dairy.customers.count
      my_dairy.update(last_assigned_sid: customer_count)
    end
  end
end
