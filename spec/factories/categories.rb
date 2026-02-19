FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "category_#{n}" }
    association :group
  end
end
