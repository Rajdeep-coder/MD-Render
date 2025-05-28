ActiveAdmin.register MyDairy do
  permit_params :dairy_name, :owner_name, :phone_number, :email, :password, :fate_rate, :I_agree_terms_and_conditions_and_privacy_policies

  scope :All do |type|
    MyDairy.all
  end

  scope :Activated do |type|
    MyDairy.joins(:rechargs).where("rechargs.expire_date > ? and rechargs.activated=1", Time.now).distinct
  end

  scope :Deactivated do |type|
    MyDairy.joins(:rechargs).where("rechargs.expire_date < ? and rechargs.activated=1", Time.now).distinct
  end

  index do
    selectable_column
    id_column
    column :dairy_name
    column :owner_name
    column :phone_number
    column :email
    column :plan
    column :expire do |variable|
      variable.rechargs.find_by(activated: true).expire_date
    end
    column :customer_count do |dairy|
      dairy.customers.count
    end
    column :last_assigned_sid
    column :created_at
    actions
  end

  filter  :plan
  filter :dairy_name
  filter :owner_name
  filter :phone_number
  filter :email

  form do |f|
    f.inputs do
      f.input :dairy_name
      f.input :owner_name
      f.input :email
      f.input :phone_number
      f.input :password
      f.input :fate_rate
      f.input :I_agree_terms_and_conditions_and_privacy_policies
    end
    f.actions
  end

  show do
    attributes_table do
      row :dairy_name
      row :owner_name
      row :phone_number
      row :email
      row :created_at
      row :updated_at
      row :plan
      row :customer_count do |dairy|
        dairy.customers.count
      end
      row :last_assigned_sid
      row :expire do |variable|
        variable.rechargs.find_by(activated: true).expire_date
      end
      row :I_agree_terms_and_conditions_and_privacy_policies

      row "Address" do |my_dairy|
        if my_dairy.address.present?
          address = my_dairy.address
          "#{address.city}, #{address.state}, #{address.pin}, #{address.country}"
        else
          "No Address Available"
        end
      end
      row :referral_code
      row :referred_by do |variable|
        MyDairy.find_by('lower(referral_code) = ?',  variable.referred_by_code&.downcase) || 'None'
      end
    end

    panel "Charts" do
      table_for my_dairy.charts do
        column :id
        column :name
        column "Actions", align: :center do |chart|
          span link_to("Edit", edit_admin_chart_path(chart), class: "button action-edit")
          span link_to("Delete", admin_chart_path(chart), method: :delete, data: { confirm: "Are you sure?" }, class: "button action-delete")
        end
      end
    end

    panel "Grades" do
      table_for my_dairy.grades do
        column :id
        column :name
        column :rate
        column "Actions", align: :center do |grade|
          span link_to("Edit", edit_admin_grade_path(grade), class: "button action-edit")
          span link_to("Delete", admin_grade_path(grade), method: :delete, data: { confirm: "Are you sure?" }, class: "button action-delete")
        end
      end
    end
  end
end
