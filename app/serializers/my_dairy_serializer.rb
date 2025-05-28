class MyDairySerializer < ActiveModel::Serializer
  attributes :id, :dairy_name, :email, :phone_number, :owner_name, :fate_rate, :image, :address, :charts, :plan_details, :customer_permissions, :clr, :snf, :fat, :last_assigned_sid, :referral_code

  def image
    return unless object.image.attached?

    {
      id: object.image.id,
      url: ENV['BASE_URL'] + Rails.application.routes.url_helpers.rails_blob_url(
        object.image, only_path: true
      )
    }
  end

  def plan_details
    plan_name = object.plan.name 
    expire_date = object.rechargs.find_by(plan_id: object.plan.id, activated: true).expire_date
    activated = Date.current <= expire_date #"09-01-2024".to_date
    { plan_name: plan_name, expire_date: expire_date, activated: activated }
  end
end
