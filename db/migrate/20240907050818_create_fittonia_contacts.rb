class CreateFittoniaContacts < ActiveRecord::Migration[7.1]
  def change
    create_table :fittonia_contacts do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone_number, null: false
      t.string :budget
      t.text :message
      t.boolean :enquiry_agreement, default: false
      t.boolean :products_agreement, default: false
      t.index :email
      t.index :phone_number

      t.timestamps
    end
  end
end
