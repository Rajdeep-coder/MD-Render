ActiveAdmin.register Chart do
  permit_params :name, :my_dairy_id

  menu parent: "MyDairy Management", label: "Charts", priority: 2

  index do
    selectable_column
    id_column
    column :name
    column :my_dairy
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :my_dairy
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs "Chart Details" do
      f.input :name
      f.input :my_dairy, as: :searchable_select, collection: MyDairy.select("CONCAT(dairy_name, ' ', '(', phone_number, ')') AS dairy_name, id")
                                                .to_a
                                                .pluck(:dairy_name, :id), prompt: "Select Dairy"
    end
    f.actions
  end

  filter :name
  filter :my_dairy, as: :select, collection: MyDairy.all.pluck(:dairy_name, :id), label: "Dairy"
end
