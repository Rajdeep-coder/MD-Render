class PlansController < ApplicationController
  skip_before_action :authenticate_request, only: %i[index]

  def index
    pagy, data = pagination(Plan.where.not(name:"Free Trail")&.order(:amount))
    render json: { data: data&.map{ |plan| PlanSerializer.new(plan) } , pagination: pagy}, status: :ok 
  end
end
  