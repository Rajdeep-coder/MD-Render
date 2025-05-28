class DepositHistoriesController < ApplicationController
  before_action :check_current_user, except: :deposit_history
  before_action :check_customer, only: %i[create update]
  before_action :find_deposit, only: %i[destroy update]

  def index
    data, meta = apply_filters
    pagy, data = pagination(data)
    render json: { data: data&.map{|deposit| DepositHistorySerializer.new(deposit) }, meta: meta , pagination: pagy}, status: :ok
  end

  def create
    deposit = DepositHistory.new(deposit_params)
    if deposit.save
      deposit.product.reduce_stock(deposit.quntity) if deposit.product
      render json: { data: DepositHistorySerializer.new(deposit), message: 'DepositHistory created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(deposit.errors) }, status: :unprocessable_entity
    end
  end

  def update
    amount = @deposit.amount
    old_quantity = @deposit.quntity
    if @deposit.update(deposit_params)
      if @deposit.product
        new_quantity = @deposit.quntity
        quantity_difference = new_quantity - old_quantity
        @deposit.product.update(stock_quantity: @deposit.product.stock_quantity - quantity_difference) if @deposit.product.stock_quantity
      end
      mange_customer_account(@deposit, amount)
      render json: { data: DepositHistorySerializer.new(@deposit), message: 'DepositHistory updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@deposit.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    quantity_to_restore = @deposit.quntity
    if @deposit.destroy
      @deposit.product.update(stock_quantity: @deposit.product.stock_quantity + quantity_to_restore) if (@deposit.product && @deposit.product.stock_quantity)
      mange_customer_account(@deposit,nil)
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end

  def deposit_history
   if @current_user.instance_of?(MyDairy)
      deposits = @current_user.customers.find_by_id(params[:customer_id])&.deposit_histories&.order(date: :desc)
      pagy, data = pagination(deposits)
      render json: { data: data&.map{ |deposit| DepositHistorySerializer.new(deposit) }, pagination: pagy }, status: :ok
    else
      deposits = @current_user.deposit_histories&.order(date: :desc)
      pagy, data = pagination(deposits)
      render json: { data: data&.map{ |deposit| DepositHistorySerializer.new(deposit) }, pagination: pagy }, status: :ok
    end
  end

  private

  def check_customer
    return if @current_user.customers.find_by_id(params[:data][:customer_id]).present?

    render json: { errors: "You have not authority to do this action" }, status: :unprocessable_entity
  end

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def deposit_params
    params.require(:data).permit(:customer_id, :product_id, :quntity, :deposit_type, :amount, :date, :note)
  end

  def find_deposit
    @deposit = DepositHistory.joins(customer: :my_dairy).where(my_dairy: { id: @current_user.id }).find_by(id: params[:id])
    return if @deposit.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end


  def apply_filters
    deposits = DepositHistory.joins(customer: :my_dairy).where(my_dairy: {id: @current_user.id})
    deposits = deposits.where(deposit_type: params[:deposit_type]) if params[:deposit_type].present?
    deposits = deposits.where(amount: params[:amount]) if params[:amount].present?
    deposits = deposits.where(customer_id: params[:customer_id]) if params[:customer_id].present?
    if params[:from_date].present? && params[:to_date].present?
      deposits = deposits.where(date: params[:from_date]..params[:to_date])
    end

    meta = {}

    if params[:meta].present?
      meta = { total_amount: deposits.sum(:amount).round(2) }
    end

    deposits = if params[:sort].present? && params[:sort][:key].present?
                  deposits.order("#{params[:sort][:key]} #{params[:sort][:direction]}")
                else
                  deposits.order(date: :desc)
                end

    [deposits.distinct, meta]
  end

  def mange_customer_account(obj, amount)
    customer_account =  obj.customer.customer_account
    if amount.present?
      deposit = customer_account.deposit  - amount
      deposit += obj.amount
    else
      deposit = customer_account.deposit  - obj.amount
    end
    balance = customer_account.credit - deposit 
    customer_account.update(deposit: deposit.round(2), balance: balance.round(2))
  end
end
