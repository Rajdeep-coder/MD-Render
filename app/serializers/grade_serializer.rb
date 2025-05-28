class GradeSerializer < ActiveModel::Serializer
  attributes :id, :name, :rate, :created_at, :updated_at
end