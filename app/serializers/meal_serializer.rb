class MealSerializer < ActiveModel::Serializer
  attributes :id, :description, :calories, :occurred_at
  has_one :user
end
