class NotificationSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :notify_type, :is_read, :customer, :my_dairy_id, :previous_data, :current_data, :created_at

  def title 
    instance_options[:locale] == "en" ? object.title : object.title_hindi     
  end

  def body
    instance_options[:locale] == "en" ? object.body : object.body_hindi
  end
end
