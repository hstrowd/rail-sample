FactoryGirl.define do

  factory :meal do |f|
    description { Faker::Lorem.paragraph }
    calories { Faker::Number.between(100, 1500) }
    occurred_at { Faker::Time.between(3.days.ago, 1.second.ago) }
    association :user
  end

end
