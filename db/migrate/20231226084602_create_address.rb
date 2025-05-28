class CreateAddress < ActiveRecord::Migration[7.1]
  def change
    create_table :addresses do |t|
      t.string :country
      t.float :latitude
      t.float :longitude
      t.string :address
      t.string :city
      t.string :district
      t.string :state
      t.string :pin
      t.references :addressable, polymorphic: true
      t.integer :address_type
      t.timestamps
    end
  end
end
