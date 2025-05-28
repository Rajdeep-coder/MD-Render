class AddIAgreeTermsAndConditionsAndPrivacyPoliciesToMyDairy < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :I_agree_terms_and_conditions_and_privacy_policies, :boolean
  end
end
