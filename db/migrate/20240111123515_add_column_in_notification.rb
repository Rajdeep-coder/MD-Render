class AddColumnInNotification < ActiveRecord::Migration[7.1]
  def change
    add_column :notifications, :current_data, :jsonb
    add_column :notifications, :previous_data, :jsonb
  end
end
