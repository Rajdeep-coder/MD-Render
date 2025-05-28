class AddReferralFieldsToMyDairy < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :referral_code, :string
    add_column :my_dairies, :referred_by_code, :string
    add_index :my_dairies, :referral_code

    MyDairy.find_each do |user|
      user.referral_code = loop do
        code = SecureRandom.hex(4)
        formatted_code = "MD#{code}" 
        break formatted_code unless MyDairy.find_by('lower(referral_code) = ?',  formatted_code.downcase).present?
      end
      user.save
    end
  end
end
