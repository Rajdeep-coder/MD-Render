ActiveAdmin.register Contact do
  permit_params :name, :email, :phone, :message

  index do
    selectable_column
    id_column
    column :name
    column :email
    column :phone
    column :message
    actions
  end

  filter :name
  filter :email
  filter :phone

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :phone
      f.input :message
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :email
      row :phone
      row :message
      row :created_at
      row :updated_at
    end
  end

end
