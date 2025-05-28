class CreateCustomers < ActiveRecord::Migration[7.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :phone_number
      t.string :email
      t.string :password_digest
      t.string :address
      t.references :my_dairy, null: false
      t.timestamps
    end
  end
end
