class ChartsController < ApplicationController
  before_action :authenticate_request, :check_current_user
  before_action :find_charts, only: %i[show destroy update]

  def index
    render json: { data: @current_user.charts.order(created_at: :asc) }, status: :ok, each_serializer: ChartSerializer
  end

  def create
    chart = @current_user.charts.new(chart_params)
    if chart.save

      render json: { data: ChartSerializer.new(chart), message: 'chart created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(chart.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: ChartSerializer.new(@chart), status: :ok }
  end


  def update
    if @chart.update(chart_params)
      render json: { data: ChartSerializer.new(@chart), message: 'chart updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@chart.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @chart.destroy
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end


  private

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def find_charts

    @chart = @current_user.charts.find_by(id: params[:id])
    return if @chart.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end


  def chart_params
    params.require(:data).permit(:name)
  end
end