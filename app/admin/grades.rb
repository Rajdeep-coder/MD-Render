ActiveAdmin.register Grade do
  permit_params :name, :rate, :my_dairy_id

  menu parent: "MyDairy Management", label: "Grades", priority: 3

  index do
    selectable_column
    id_column
    column :name
    column :rate
    column :my_dairy
    actions
  end

  filter :name
  filter :rate
  filter :my_dairy

  form do |f|
    f.inputs do
      f.input :name
      f.input :rate
      f.input :my_dairy, as: :searchable_select, collection: MyDairy.select("CONCAT(dairy_name, ' ', '(', phone_number, ')') AS dairy_name, id")
                                                .to_a
                                                .pluck(:dairy_name, :id), prompt: "Select Dairy"
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :rate
      row :my_dairy
      row :created_at
      row :updated_at
    end
  end
end