# app/admin/logos.rb

ActiveAdmin.register Fittonia::Career do
  menu parent: 'Fittonia'
  permit_params :first_name,:last_name,:email,:phone_number,:gender,:address,:education,:experiance, :status, :resume, {skill: [] }

    scope :application_received
    scope :shortlisted
    scope :written_exam_cleared
    scope :technical_interview_passed
    scope :hr_interview_cleared
    scope :on_hold
    scope :hiring_closed
    scope :not_selected
    scope :hiring_open


  index do
    selectable_column
    id_column
    column :first_name
    column :last_name
    column :email
    column :phone_number
    column "Resume" do |document|
      link_to "resume", document.resume, target: "_self" if document.resume.attached?
    end
    column :status do |candidate|
      candidate.status.to_s.humanize
    end
    column :created_at
    actions
  end

  filter :name

  form do |f|
    f.inputs 'Career Form' do
      f.input :first_name
      f.input :last_name
      f.input :email
      f.input :phone_number
      f.input :gender
      f.input :address
      f.input :education
      f.input :skill, as: :string, input_html: { multiple: true }
      f.input :experiance
      f.input :resume, as: :file
      f.input :status
    end
    f.actions
  end

  show do
    attributes_table do
      row :first_name
      row :last_name
      row :email
      row :phone_number
      row :address
      row :education
      row :skill
      row :experiance
      row :gender
      row :resume do |logo|
        if logo.resume.attached?
          ENV['BASE_URL'] + url_for(logo.resume)
        else
          'No resume'
        end
      end
      row :status do |candidate|
        candidate.status.to_s.humanize
      end
      row :created_at
      row :updated_at
    end
  end
end
