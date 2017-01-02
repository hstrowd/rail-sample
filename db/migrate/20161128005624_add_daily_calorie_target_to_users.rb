class AddDailyCalorieTargetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :daily_calorie_target, :integer, null: false, default: 1500
  end
end
