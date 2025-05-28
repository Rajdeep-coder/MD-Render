class BuyMilkSerializer < ActiveModel::Serializer
  attributes :id, :fat, :clr, :snf, :quntity, :amount, :shift, :date, :rate_type, :chart, :customer, :grade, :little_rate
end
