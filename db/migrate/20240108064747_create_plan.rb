class CreatePlan < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name  
      t.integer :validity  
      t.float :amount 
      t.timestamps
    end
  end
end
