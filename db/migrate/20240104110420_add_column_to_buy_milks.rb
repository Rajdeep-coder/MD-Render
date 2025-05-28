class AddColumnToBuyMilks < ActiveRecord::Migration[7.1]
  def change
    add_column :buy_milks, :shift, :integer
    add_column :buy_milks, :date, :date
    add_column :buy_milks, :rate_type, :integer
    add_column :buy_milks, :chart_id, :integer
  end
end
