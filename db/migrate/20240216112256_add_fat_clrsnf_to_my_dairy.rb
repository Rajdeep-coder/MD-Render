class AddFatClrsnfToMyDairy < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :fat, :boolean, default: false
    add_column :my_dairies, :snf, :boolean, default: false
    add_column :my_dairies, :clr, :boolean, default: false
  end
end
