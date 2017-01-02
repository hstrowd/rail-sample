class Meal < ActiveRecord::Base
  include Serializable

  belongs_to :user

  validates_presence_of :user, :description, :calories, :occurred_at
  validates :calories, numericality: { greater_than: 0, less_than: 3000 }
  validates :description, length: { maximum: 2000 }
end
