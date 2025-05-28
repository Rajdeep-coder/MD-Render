class MyDairiesController < ApplicationController
  skip_before_action :authenticate_request, only: %i[create]
  before_action :check_password, :check_exicting_phone_number, only: %i[create]
  # def index
  #   render json: { data: MyDairy.all }, status: :ok, each_serializer: MyDairySerializer
  # end

  def create
    milk_dairy = MyDairy.new(milk_dairy_params)
    if milk_dairy.save
      
      render json: { data: MyDairySerializer.new(milk_dairy), 
                     token: jwt_encode(my_dairy_id: milk_dairy.id),
                     role: "MyDairy",
                     message: 'milk_dairy created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(milk_dairy.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @current_user&.update(milk_dairy_update_params)
      render json: { data: MyDairySerializer.new(@current_user), message: 'milk_dairy updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@current_user.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: MyDairySerializer.new(@current_user), summery: day_summery, status: :ok }
  end

  def destroy
    if @current_user.destroy
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end

  private

  def day_summery
    if params[:date].present?
      buy_milks = BuyMilk.joins(customer: :my_dairy).where(my_dairy: { id: @current_user.id }, date: params[:date])
      morning = get_meta(buy_milks.where(shift: :morning))
      evening = get_meta(buy_milks.where(shift: :evening))
      {
        morning: morning,
        evening: evening
      }
    else
      {
        morning: {},
        evening: {}
      }
    end
  end

  def get_meta(buy_milks)
    return {} if buy_milks.empty?

    fat_avg = clr_avg = snf_avg = 0
    buy_milks.each do |obj|
      fat_avg += (obj.fat * obj.quntity) 
      clr_avg += (obj.clr * obj.quntity)  if obj.clr.present?
      snf_avg += (obj.snf * obj.quntity)  if obj.snf.present?
    end
    total_quntity = buy_milks.sum(:quntity)&.round(2)
    { 
     total_quntity: total_quntity,
     total_amount: buy_milks.sum(:amount)&.round(2),
     fat_avg: (fat_avg/total_quntity)&.round(2),
     snf_avg: (snf_avg/total_quntity)&.round(2),
     clr_avg: (clr_avg/total_quntity)&.round(2),
     count: buy_milks.count, 
    }
  end

  def milk_dairy_params
    params.require(:data).permit(:dairy_name, :email, :phone_number, :password, :owner_name, :referred_by_code, :fate_rate, :fat, :clr, :snf, :I_agree_terms_and_conditions_and_privacy_policies,
                                 address_attributes: %i[country latitude longitude address address_type city district state
                                                        pin])
  end

  def milk_dairy_update_params
    params.require(:data).permit(:dairy_name, :email, :phone_number, :owner_name, :fate_rate, :image, :fat, :clr, :snf,
                                 address_attributes: %i[country latitude longitude address address_type city district state
                                                        pin], customer_permissions: [
      accountDetails: [:parent, :creditedAmount, :debitedAmount],
      creditHistory: [:parent, :amount, :clr, :snf],
      depositHistory: [:parent],
      notifications: [:parent, :amount, :clr, :snf]
    ])
  end

  def check_password
    return if params[:data][:password] == params[:data][:confirm_password]

    render json: { errors: { password: 'password and confirm_password does not match' } }, status: :unprocessable_entity
  end

  def check_exicting_phone_number
    existing_customer = Customer.find_by(phone_number: milk_dairy_params[:phone_number])

    return unless existing_customer.present?

    render json: { errors: { phone_number: 'Phone number already belongs to a Customer' } },
           status: :unprocessable_entity
  end
end
