ActiveAdmin.register Customer do
  permit_params :name, :email, :phone_number, :password, :address, :my_dairy_id

  filter :my_dairy, as: :select, collection: -> { MyDairy.select("CONCAT(dairy_name, ' ', '(', phone_number, ')') as dairy_name, id").to_a.pluck(:dairy_name, :id) }

  index do
    selectable_column
    id_column
    column :name
    column :phone_number
    column :email
    column :address
    column :my_dairy
    actions
  end

  filter :name
  filter :email
  filter :phone_number

  form do |f|
    f.inputs do
      f.input :name
      f.input :email
      f.input :phone_number
      f.input :password
      f.input :address
      f.input :my_dairy
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :phone_number
      row :email
      row :address
      row :my_dairy
      row :created_at
      row :updated_at
    end
  end

end
