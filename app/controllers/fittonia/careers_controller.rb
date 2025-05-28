class Fittonia::CareersController < ApplicationController
  skip_before_action :authenticate_request

  def create 
    @career = Fittonia::Career.new(career_params)
    if @career.save
      render json: { data: @career.json_data, message: "Career form has successfully submitted" }
    else
      render json: { errors: @career.errors }
    end
  end

  private
  def career_params
    params.permit(:first_name,:last_name,:email,:phone_number,:address,:gender,:education,:experiance,:resume,skill: [])
  end
end
