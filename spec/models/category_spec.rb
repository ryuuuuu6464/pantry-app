require "rails_helper"

RSpec.describe Category, type: :model do
  describe "カテゴリーのバリデーションに関するテスト" do
    it "カテゴリー名が無い場合は無効であること" do
      # カテゴリー名が空欄のカテゴリーを作成
      category_without_name = FactoryBot.build(:category, name: "")
      # 作成したカテゴリーが無効か確認
      expect(category_without_name).to be_invalid
    end

    it "カテゴリー名が12文字以下の場合は有効であること" do
      # カテゴリー名が12文字のカテゴリーを作成
      category_less_than_name = FactoryBot.build(:category, name: "a" * 12)
      # 作成したカテゴリーが有効か確認
      expect(category_less_than_name).to be_valid
    end

    it "カテゴリー名が13文字以上の場合は無効であること" do
      # カテゴリー名が13文字のカテゴリーを作成
      category_more_than_name = FactoryBot.build(:category, name: "a" * 13)
      # 作成したカテゴリーが無効か確認
      expect(category_more_than_name).to be_invalid
    end

    it "カテゴリーはグループに紐づいていること" do
      # 検証するカテゴリーを作成
      category = create(:category)
      # 作成したカテゴリーにgroup_idが存在するか確認
      expect(category.group_id).to be_present
    end

    it "グループ内でカテゴリー名が重複しないこと" do
      # グループを作成
      group = create(:group)
      # カテゴリーを作成
      category = create(:category, name: "食料品", group_id: group.id)
      # 同じグループで名前が重複するカテゴリーを作成
      duplicate_category = FactoryBot.build(:category, name: "食料品", group_id: group.id)
      # 名前が重複するカテゴリーが無効か確認
      expect(duplicate_category).to be_invalid
    end

    it "グループが別の場合は同じカテゴリー名を命名できること" do
      # グループ1を作成
      group1 = create(:group)
      # グループ2を作成
      group2 = create(:group)
      # グループ1にカテゴリーを作成
      category = create(:category, name: "食料品", group_id: group1.id)
      # グループ2に同じ名前のカテゴリーを作成
      duplicate_category = FactoryBot.build(:category, name: "食料品", group_id: group2.id)
      # グループ2に作成したカテゴリーが有効か確認
      expect(duplicate_category).to be_valid
    end
  end
end
