class AddDecodeTextToCustomer < ActiveRecord::Migration[7.1]
  def change
    add_column :customers, :decode_text, :string
  end
end
