class ProductsController < ApplicationController
  before_action :authenticate_request
  before_action :check_current_user, except: :show
  before_action :find_product, only: %i[show destroy update]

  def index
    data = @current_user.products.order(created_at: :asc)
    render json: { data: data&.map{ |product| ProductSerializer.new(product) } }, status: :ok 
  end

  def create
    product = @current_user.products.new(product_params)
    if product.save
      render json: { data: ProductSerializer.new(product), message: 'product created successfully' },
             status: :created
    else
      render json: { errors: format_activerecord_errors(product.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      render json: { data: ProductSerializer.new(@product), message: 'product updated successfully' },
             status: :ok
    else
      render json: { errors: format_activerecord_errors(@product.errors) }, status: :unprocessable_entity
    end
  end

  def show
    render json: { data: ProductSerializer.new(@product), status: :ok }
  end

  def destroy
    if @product.destroy
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

  def product_params
    params.require(:data).permit(:name, :amount, :stock_quantity)
  end

  def find_product
    @product = Product.joins(:my_dairy).where(my_dairy: {id: @current_user.id}).find_by(id: params[:id])
    return if @product.present?

    render json: { errors: 'Record not found ' }, status: :unprocessable_entity
  end
end
