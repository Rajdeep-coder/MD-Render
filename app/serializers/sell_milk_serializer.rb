class SellMilkSerializer < ActiveModel::Serializer
  attributes :id, :avg_fat, :avg_clr, :avg_snf, :total_quntity, :total_amount, :fat, :clr,:snf, :quntity, :amount,
             :benifit, :weight_lose, :shift, :date ,:my_dairy
end
