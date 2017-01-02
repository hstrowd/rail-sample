class User < ActiveRecord::Base
  ADMIN_ROLE = 'admin'
  USER_MANAGER_ROLE = 'user_manager'
  BASIC_ROLE = 'basic'
  ROLES = {
    BASIC_ROLE => 0,
    USER_MANAGER_ROLE => 1,
    ADMIN_ROLE => 2
  }

  # Include default devise modules.
  devise :database_authenticatable, :registerable,
          :trackable, :validatable
  include DeviseTokenAuth::Concerns::User
  include Serializable

  has_many :meals

  validates_presence_of :name, :daily_calorie_target, :role
  validates :daily_calorie_target, numericality: { greater_than: 0, less_than: 10000 }
  validates :role, inclusion: { in: ROLES }

  def admin?
    self.role == ADMIN_ROLE
  end

  def user_manager?
    self.role == USER_MANAGER_ROLE
  end

  def basic?
    self.role == BASIC_ROLE
  end
end
