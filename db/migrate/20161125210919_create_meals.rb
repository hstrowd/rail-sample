class CreateMeals < ActiveRecord::Migration
  def change
    create_table :meals do |t|
      t.integer :user_id, null: false
      t.string :description, null: false, default: ''
      t.integer :calories, null: false
      t.datetime :occurred_at, null: false

      t.timestamps null: false
    end

    add_index :meals, [:user_id, :occurred_at]
  end
end
