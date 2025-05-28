class CreateChartRate < ActiveRecord::Migration[7.1]
  def change
    create_table :chart_rates do |t|
      t.bigint :chart_id
      t.float :fat 
      t.float :clr
      t.float :snf 
      t.float :rate 
      t.timestamps
    end
  end
end
