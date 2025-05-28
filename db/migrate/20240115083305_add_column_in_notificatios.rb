class AddColumnInNotificatios < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :title_hindi, :string
    add_column :notifications, :body_hindi, :string
  end
end
