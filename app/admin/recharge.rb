ActiveAdmin.register Recharg do
  permit_params :my_dairy, :plan, :my_dairy_id, :plan_id

  filter  :plan
  filter :my_dairy, as: :select, collection: -> { MyDairy.select("CONCAT(dairy_name, ' ', '(', phone_number, ')') as dairy_name, id").to_a.pluck(:dairy_name, :id) }

  index do
    selectable_column
    id_column
    column "Dairy Name" do |variable|
      variable.my_dairy&.dairy_name
    end
    column :plan
    column :activated
    column :expire_date
    column :Amount do |variable|
      variable&.plan&.amount
    end
    actions
  end

  filter :activated

  form do |f|
    f.inputs do
      f.input :my_dairy_id, as: :searchable_select, collection: MyDairy.select("CONCAT(dairy_name, ' ', '(', phone_number, ')') as dairy_name, id").to_a.pluck(:dairy_name, :id)
      f.input :plan_id, as: :select, collection: Plan.all.pluck(:name, :id)
    end
    f.actions
  end

  show do
    attributes_table do
      row "Dairy Name" do |variable|
        variable.my_dairy.dairy_name
      end
      row :plan
      row :activated
      row :expire_date
      row :Amount do |variable|
        variable&.plan&.amount
      end
    end
  end

end
