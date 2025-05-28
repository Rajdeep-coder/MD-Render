class PlanSerializer < ActiveModel::Serializer
  attributes :id, :name, :amount, :validity
end
