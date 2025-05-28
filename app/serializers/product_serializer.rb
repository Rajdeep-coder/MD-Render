class ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :amount, :my_dairy, :sid, :stock_quantity
end
