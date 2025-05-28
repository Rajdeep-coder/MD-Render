class ForgetPasswordController < ApplicationController
  before_action :decode_token, only: :verify_otp
  before_action :check_password_length , only: :forget_password
  before_action :check_email_or_phone, only: :send_otp
  skip_before_action :authenticate_request, only: %i[ send_otp verify_otp]

  def send_otp
    otp = Otp.create( otp: rand.to_s[2..5], email: @my_dairy.email, phone_number: @my_dairy.phone_number )
    MyDairyMailer.send_otp(otp).deliver_later
    data = {  message: 'send otp', token: jwt_encode(otp_id: otp.id), email: @my_dairy.email }
    render json: data, status: :ok
  end

  def verify_otp
    if @otp.otp.eql?(params[:data][:otp])
      my_dairy = MyDairy.find_by("email ="+"'#{@otp.email}'"+"or  phone_number ="+"'#{@otp.phone_number}'" )
      data = {  message: 'verifed', token: jwt_encode(my_dairy_id: my_dairy.id) } 
      render json: data, status: :ok 
    else
      render json: { errors: { otp: 'otp does not match !' } },status: :unprocessable_entity
    end
  end

  def forget_password
    if params[:data][:password] == params[:data][:confirm_password]
      if @current_user.update(password: params[:data][:password])
        render json: { message: 'password forget successfully !' }
      else
        render json: { errors: format_activerecord_errors(@current_user.errors) }, status: :unprocessable_entity
      end
    else
      render json: { errors: { password: 'password and confirm password does not match' } }, status: :unprocessable_entity
    end
  end

  private

  def decode_token
    token = request.headers['token']
    decoded = jwt_decode(token)
    @otp = Otp.find_by_id(decoded[:otp_id]) 
  end

  def check_email_or_phone
    # @my_dairy =  MyDairy.find_by(email: params[:data][:email]) || MyDairy.find_by(phone_number: params[:data][:phone_number])
    @my_dairy = MyDairy.find_by("email = "+"'#{params[:data][:email]}' or phone_number = "+"'#{params[:data][:email]}'")
    unless @my_dairy.present?
      render json: { errors: { email: 'Invalid email or phone number' } }, status: :unprocessable_entity
    end
  end

  def check_password_length
    password = params[:data][:password].length
    unless password >= 8 && password <= 12
     render json: { errors: { password: 'Password must be minimum 8 characters and maximum 12 characters' } }, status: :unprocessable_entity
    end
  end
end
