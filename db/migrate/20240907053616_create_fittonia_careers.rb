class CreateFittoniaCareers < ActiveRecord::Migration[7.1]
  def change
    create_table :fittonia_careers do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.bigint :phone_number
      t.string :address
      t.string :gender
      t.string :education
      t.string :skill, array: true, default: []
      t.string :experiance
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
