class SellMilksController < ApplicationController
  before_action :authenticate_request
  before_action :check_current_user, except: :show
  before_action :find_sell_milk, only: %i[show destroy update]

  def index
    data, meta = apply_filters
    pagy, data = pagination(data)
    render json: { data: data&.map{ |sell_milk| SellMilkSerializer.new(sell_milk) }, meta: meta, pagination: pagy }, status: :ok 
  end

  def create
    sell_milk = @current_user.sell_milks.new(sell_milk_params)
    if sell_milk.save
      render json: { data: SellMilkSerializer.new(sell_milk), message: 'sell_milk created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(sell_milk.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @sell_milk.update(sell_milk_params)
      render json: { data: SellMilkSerializer.new(@sell_milk), message: 'sell_milk updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@sell_milk.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: SellMilkSerializer.new(@sell_milk) }, status: :ok
  end

  def destroy
    if @sell_milk.destroy
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end

  def graph_data
    sell_milks = @current_user.sell_milks
    total_earning = sell_milks.sum(:benifit).round(2)
    sell_milks = sell_milks.where(date: params[:from_date]..params[:to_date]).group(:date).select("date as key, SUM(benifit) as value")

    render json: { data: sell_milks&.order(:date), meta: { total_earning: total_earning } }, status: :ok
  end

  def apply_filters
    sell_milks = @current_user.sell_milks
    sell_milks = sell_milks.where(shift: params[:shift]) if params[:shift].present?

    if params[:from_date].present? && params[:to_date].present?
      sell_milks = sell_milks.where(date: params[:from_date]..params[:to_date])
    end

    meta = {}

    if params[:meta].present?
      meta = { total_quntity: sell_milks.sum(:quntity)&.round(2),
               total_amount: sell_milks.sum(:amount)&.round(2),
               total_benifit: sell_milks.sum(:benifit)&.round(2) }
    end

    sell_milks = if params[:sort].present? && params[:sort][:key].present?
                  sell_milks.order("#{params[:sort][:key]} #{params[:sort][:direction]}")
                else
                  sell_milks.order(date: :desc)
                end

    [sell_milks, meta]
  end

  private

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def sell_milk_params
    params.require(:data).permit(:avg_fat, :avg_clr, :avg_snf, :total_quntity, :total_amount, :fat, :clr,
                                 :snf, :quntity, :amount, :benifit, :weight_lose, :shift, :date )
  end

  def find_sell_milk
    @sell_milk = SellMilk.joins(:my_dairy).where(my_dairy: {id: @current_user.id}).find_by(id: params[:id])
    return if @sell_milk.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end
end
