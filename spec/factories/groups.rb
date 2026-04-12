FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "group_#{n}" }
    is_guest { false }

    # ゲスト用グループ
    trait :guest do
      is_guest { true }
    end
  end
end
