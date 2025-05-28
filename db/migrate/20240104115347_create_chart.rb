class CreateChart < ActiveRecord::Migration[7.1]
  def change
    create_table :charts do |t|
      t.bigint :my_dairy_id
      t.string :name 
      t.timestamps
    end
  end
end
