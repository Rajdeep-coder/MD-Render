class ChartRateSerializer < ActiveModel::Serializer
  attributes :id, :fat, :clr, :snf, :rate, :chart_id
end