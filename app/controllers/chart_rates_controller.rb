class ChartRatesController < ApplicationController
  before_action :authenticate_request, :check_current_user
  before_action :check_charts, only: %i[create build_chart_rate clear_chart_rate]
  before_action :find_chart_rates, only: %i[show destroy update]

  def index
    data = apply_filter
    pagy = {}
    pagy, data = pagination(data) if params[:pagy]
    render json: { data: data, pagination: pagy }, status: :ok, each_serializer: ChartRateSerializer
  end

  def create
    chart_rate = @chart.chart_rates.new(chart_rate_params)

    if chart_rate.save
      render json: { data: ChartRateSerializer.new(chart_rate), message: 'Chart rate created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(chart_rate&.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: ChartRateSerializer.new(@chart_rate), status: :ok }
  end


  def update
    if @chart_rate.update(chart_rate_params)
      render json: { data: ChartRateSerializer.new(@chart_rate), message: 'chart_rate updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@chart_rate.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @chart_rate.destroy
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end

  def build_chart_rate
    @chart.chart_rates
    if params[:data][:rate_type] == 'clr'
      create_chart_clr
    else
      create_chart_snf
    end
    render json: { data: @chart.chart_rates.order(created_at: :asc) }, status: :ok, each_serializer: ChartRateSerializer
  end

  def clear_chart_rate
    @chart.chart_rates.destroy_all
    render json: { data: @chart.chart_rates.order(created_at: :asc) }, status: :ok, each_serializer: ChartRateSerializer
  end

  def per_litter_price
    chart_rates = ChartRate.joins(:chart).where('charts.my_dairy_id = ? AND chart_id = ?', @current_user.id, params[:chart_id])
     rate = if params[:clr].present?
              value = params[:clr]
              key = 'chart_rate_not_found'
              chart_rates.find_by(fat: params[:fat], clr: params[:clr])
            else
              value = params[:snf]
              key = 'chart_rate_not_found_snf'
              chart_rates.find_by(fat: params[:fat], snf: params[:snf])
            end
    if rate.present?
      render json: { data: rate }, status: :ok
    else
      render json: { message: t(key, fat: params[:fat], clr: value) }, status: :ok
    end
  end

  private

  def create_chart_clr
    fat = params[:data][:from_fat].to_f
    clr = params[:data][:clr].to_f
    per_fat_rate = params[:data][:per_fat_rate].to_f
    til = params[:data][:to_fat].to_f
    while til >= fat
      chart = @chart.chart_rates.find_or_create_by(fat: fat, clr: clr)
      snf = caculate_snf(clr, fat).round(2)
      rate = (fat * per_fat_rate).round(2)
      chart.update(snf: snf, rate: rate)
      fat = (fat + 0.1).round(1)
    end
  end

  def create_chart_snf
    fat = params[:data][:from_fat].to_f
    snf = params[:data][:snf].to_f
    per_fat_rate = params[:data][:per_fat_rate].to_f
    til = params[:data][:to_fat].to_f

    while til >= fat
      chart = @chart.chart_rates.find_or_create_by(fat: fat, snf: snf)
      clr = caculate_clr(snf, fat).round
      rate = (fat * per_fat_rate).round(2)
      chart.update(clr: clr, rate: rate)
      fat = (fat + 0.1).round(1)
    end
  end

  def caculate_snf(clr, fat)
    (clr/4) + (0.21 * fat) + 0.66
  end

  def caculate_clr(snf, fat)
    (snf - (0.21 * fat) - 0.66) * 4
  end

  def apply_filter
    chart_rates = ChartRate.joins(:chart).where('charts.my_dairy_id = ?', @current_user.id)
    chart_rates = chart_rates.where(chart_id: params[:chart_id]) if params[:chart_id].present?
    chart_rates.order(created_at: :asc)
  end

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def check_charts
    @chart = @current_user.charts.find_by(id: params[:chart_id] || params[:data][:chart_id])
    return if @chart.present?

    render json: { errors: 'chart not found' },status: :unprocessable_entity
  end

  def find_chart_rates
    chart_rate = ChartRate.joins(:chart).where('charts.my_dairy_id = ?',@current_user.id)

    @chart_rate = chart_rate.find_by(id: params[:id])
    return if @chart_rate.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end

  def chart_rate_params
    params.require(:data).permit(:fat, :clr, :snf, :rate, :chart_id)
  end
end
