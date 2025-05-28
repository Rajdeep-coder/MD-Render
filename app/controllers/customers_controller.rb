class CustomersController < ApplicationController
  before_action :authenticate_request
  before_action :find_customer, only: %i[show destroy update]
  before_action :check_current_user, except: :show
  before_action :check_exicting_phone_number, :check_password, only: %i[create]

  def index
    render json: { data: filter_customer&.order(:sid).map(&:respose_date) }, status: :ok
  end

  def create
    customer = @current_user.customers.new(customer_params)
    if customer.save

      render json: { data: CustomerSerializer.new(customer), message: 'customer created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(customer.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      render json: { data: CustomerSerializer.new(@customer), message: 'customer updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@customer.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: CustomerSerializer.new(@customer), status: :ok }
  end

  def destroy
    if @customer.destroy
      render json: { message: 'Record delete successfully' }, status: :ok
    else
      render json: { errors: 'Failed to deleted' }, status: :unprocessable_entity
    end
  end

  private

  def customer_params
    params.require(:data).permit(:name, :email, :phone_number, :password, :image, :address, :grade_id, :chart_id, :rate_type, :sid,
                                 address_attributes: %i[country latitude longitude address address_type])
  end

  def check_current_user
    return if @current_user.instance_of?(MyDairy)

    render json: { errors: 'You have not authority to do this action' },status: :unprocessable_entity
  end

  def check_password
    return if params[:data][:password] == params[:data][:confirm_password]

    render json: { errors: { password:'password and confirm_password does not match'} }, status: :unprocessable_entity
  end

  def check_exicting_phone_number
    existing_customer = MyDairy.find_by(phone_number: customer_params[:phone_number])

    return unless existing_customer.present?

    render json: { errors: { phone_number: 'Phone number already belongs to a my dairy' } },
           status: :unprocessable_entity
  end

  def find_customer
    @customer = if @current_user.instance_of?(MyDairy)
                  @current_user.customers.find_by(id: params[:id])
                else
                  @current_user
                end
    return if @customer.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end

  def filter_customer
    customers = @current_user.customers
    if params[:search].present?
      customers = customers.where("sid = :id or name ILIKE :search OR address ILIKE :search",
                    search: "%#{params[:search]}%", id: "#{params[:search].to_i}")
    end

    customers
  end
end
