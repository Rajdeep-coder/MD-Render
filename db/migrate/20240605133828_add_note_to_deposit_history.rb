class AddNoteToDepositHistory < ActiveRecord::Migration[7.1]
  def change
    add_column :deposit_histories, :note, :text
  end
end
