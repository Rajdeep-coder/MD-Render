class AddColumnToMyDairy < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :otp, :string
  end
end
