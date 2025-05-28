class AddCustomerPermissionsToMyDairies < ActiveRecord::Migration[7.1]
  def change
    add_column :my_dairies, :customer_permissions, :jsonb, default: {
      "accountDetails": {
        "parent": "true",
        "creditedAmount": "true",
        "debitedAmount": "true"
      },
      "creditHistory": {
        "parent": "true",
        "amount": "true",
        "clr": "true",
        "snf": "true"
      },
      "depositHistory": {
        "parent": "true"
      },
      "notifications": {
        "parent": "true",
        "amount": "true",
        "clr": "true",
        "snf": "true"
      }
    }
  end
end
