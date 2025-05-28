ActiveAdmin.register Plan do
  permit_params :name, :validity, :amount 

  index do
    selectable_column
    id_column
    column :name
    column :validity
    column :amount
    actions
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :validity
      f.input :amount
    end
    f.actions
  end

  show do
      attributes_table do
      row :name
      row :validity
      row :amount
      row :created_at
      row :updated_at
    end
  end
end
