FactoryBot.define do
  factory :item do
    sequence(:name) { |n| "item_#{n}" }
    # categoryを1つ作ってitemに紐づける
    association :category
    # itemのgroupは「categoryが属しているgroup」と同じものを使う
    group { category.group }
    # 別のグループのアイテム
    trait :different_group_category do
      # itemのgroupを別グループに差し替える
      association :group
    end
  end
end
