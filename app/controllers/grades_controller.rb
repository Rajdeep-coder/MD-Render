class GradesController < ApplicationController
  before_action :authenticate_request, :check_current_user
  before_action :find_grade, only: [:update, :destroy]

  def index
    render json: { data: current_user.grades.order(created_at: :asc) }, status: :ok, each_serializer: GradeSerializer
  end

  def create
    grade = current_user.grades.new(grade_params)

    if grade.save
      render json: { data: GradeSerializer.new(grade), message: 'Grade created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(grade&.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @grade.update(grade_params)
      render json: { data: GradeSerializer.new(@grade), message: 'Grade updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@grade.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @grade.customers.present?
      render json: { message: 'Customers are alredy assoicate with this grade', customers: @grade.customers.pluck(:sid) }, status: :ok
    elsif @grade.destroy
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end

  def find_grade
    @grade = current_user.grades.find_by(id: params[:id])
    return if @grade.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def grade_params
    params.require(:data).permit(:name, :rate)
  end
end