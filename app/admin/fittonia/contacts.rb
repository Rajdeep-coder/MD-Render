# app/admin/logos.rb

ActiveAdmin.register Fittonia::Contact do
  menu parent: 'Fittonia'
  permit_params :first_name, :last_name, :email, :phone_number, :message

  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone_number
    column :message
    column :created_at
    actions
  end

  filter :first_name
  filter :last_name
  filter :email
  filter :phone_number
  filter :message
  filter :created_at

  form do |f|
    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone_number
      f.input :message
      f.input :budget
    end
    f.actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :phone_number
      row :message
      row :budget
      row :enquiry_agreement
      row :products_agreement
      row :created_at
      row :updated_at
    end
  end
end
