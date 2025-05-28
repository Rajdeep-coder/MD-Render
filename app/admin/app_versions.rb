ActiveAdmin.register AppVersion do
  permit_params :name, :platform, :version, :required

  index do
    selectable_column
    id_column
    column :name
    column :platform
    column :version
    column :required
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :platform
      row :version
      row :required
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  filter :name
  filter :platform, as: :select, collection: ["android", "ios"]
  filter :version
  filter :required
  filter :created_at

  form do |f|
    f.inputs "App Version Details" do
      f.input :name, label: "App Name", hint: "Specify the app name (e.g., 'MilkDairyApp')"
      f.input :platform, as: :searchable_select, collection: ["android", "ios"], include_blank: false
      f.input :version, hint: "Enter version number (e.g., 1.2.3)"
      f.input :required, label: "Mandatory Update?", as: :boolean
    end
    f.actions
  end
end
