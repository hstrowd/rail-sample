class UserSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :daily_calorie_target, :meal_count, :calorie_total, :role, :created_at

  def meal_count
    object.meals.count
  end

  def calorie_total
    object.meals.collect(&:calories).sum
  end
end
