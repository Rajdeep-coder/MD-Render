class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def login
    user = find_user_by_email_or_phone_number(params[:data][:email])
    if user.present?
      if user.authenticate(params[:data][:password])
        create_device_token(user)
        render_user_json(user)
      else
        render json: { errors: { password: 'Invalid Password' } }, status: :unauthorized
      end
    else
      render json: { errors: { email: 'Invalid Email/Phone Number' } }, status: :unauthorized
    end
  end

  private

  def find_user_by_email_or_phone_number(email)
    my_dairy = MyDairy.find_by("email = "+"'#{email}' or phone_number = "+"'#{email}'")
    return my_dairy if my_dairy.present?

    return Customer.find_by_phone_number(email)
  end

  def render_user_json(user)
    if user.instance_of?(MyDairy)
      render json: { token: jwt_encode(my_dairy_id: user.id), data: MyDairySerializer.new(user), role: "MyDairy" }, status: :ok
    else
      render json: { token: jwt_encode(customer_id: user.id), data: CustomerSerializer.new(user), role: "Customer" }, status: :ok
    end
  end

  def create_device_token(user)
    token = params[:data][:token]
    if user.instance_of?(MyDairy)
      DeviceToken.create(device_token: token, my_dairy_id: user.id)
    else
      DeviceToken.create(device_token: token, customer_id: user.id)
    end
  end
end
