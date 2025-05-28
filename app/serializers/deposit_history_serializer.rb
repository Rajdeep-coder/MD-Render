class DepositHistorySerializer < ActiveModel::Serializer
  attributes :id, :deposit_type, :quntity, :amount, :customer, :product, :date, :note
end
