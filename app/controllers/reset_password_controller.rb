class ResetPasswordController < ApplicationController
  before_action :check_old_password, :check_password_length , only: :create

  def create
    if params[:data][:new_password] == params[:data][:confirm_new_password]
      if @current_user.update(password: params[:data][:new_password])
        render json: { message: 'password reset successfully !' }
      else
        render json: { errors: format_activerecord_errors(@current_user.errors) }, status: :unprocessable_entity
      end
    else
      render json: { errors: { password: 'new password and confirm new password does not match' } }, status: :unprocessable_entity
    end
  end

  private

  def check_password_length
    password = params[:data][:new_password].length
    unless password >= 8
     render json: { errors: { new_password: 'Password must be minimum 8 characters' } }, status: :unprocessable_entity
    end
  end

  def check_old_password
   return  if @current_user.authenticate(params[:data][:old_password])

   render json: { errors: { old_password: 'Invalid Password !' } }, status: :unprocessable_entity
  end
end
