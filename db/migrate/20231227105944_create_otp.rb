class CreateOtp < ActiveRecord::Migration[7.1]
  def change
    create_table :otps do |t|
      t.string :email
      t.string :phone_number 
      t.string :otp 
      t.timestamps
    end
  end
end
