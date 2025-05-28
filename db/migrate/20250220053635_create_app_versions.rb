class CreateAppVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :app_versions do |t|
      t.string :name
      t.string :platform
      t.string :version
      t.boolean :required, default: false

      t.timestamps
    end
  end
end
