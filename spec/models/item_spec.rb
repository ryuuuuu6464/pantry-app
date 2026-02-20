require "rails_helper"

RSpec.describe Item, type: :model do
  describe "アイテムのバリデーションに関するテスト" do
    it "アイテム名が無い場合は無効であること" do
      # アイテム名が空欄のアイテムを作成
      item_without_name = FactoryBot.build(:item, name: "")
      # 作成したアイテムが無効か確認
      expect(item_without_name).to be_invalid
    end

    it "アイテム名が12文字以下の場合は有効であること" do
      # アイテム名が12文字のアイテムを作成
      item_less_than_name = FactoryBot.build(:item, name: "a" * 12)
      # 作成したアイテムが有効か確認
      expect(item_less_than_name).to be_valid
    end

    it "アイテム名が13文字以上の場合は無効であること" do
      # アイテム名が13文字のアイテムを作成
      item_name_13 = FactoryBot.build(:item, name: "a" * 13)
      # 作成したアイテムが無効か確認
      expect(item_name_13).to be_invalid
    end

    it "同じグループ内でアイテム名が重複しないこと" do
      # アイテムが紐づくグループを作成
      group = create(:group)
      # 作成したグループに紐づくカテゴリーを作成
      category = create(:category, group: group)
      # アイテム名が牛乳のアイテムを作成
      item = create(:item, name: "牛乳", group: group, category: category)
      # 重複名のアイテムを作成
      duplicate_item = build(:item, name: "牛乳", group: group, category: category)
      # 重複名のアイテムが無効か確認
      expect(duplicate_item).to be_invalid
    end

    it "別のグループで同じアイテム名が有効であること" do
      # グループ1を作成
      group1 = create(:group)
      # グループ2を作成
      group2 = create(:group)
      # グループ1に紐づくカテゴリー1を作成
      category1 = create(:category, group: group1)
      # グループ2に紐づくカテゴリー2を作成
      category2 = create(:category, group: group2)
      # グループ1にアイテム名が牛乳のアイテムを作成
      create(:item, name: "牛乳", group: group1, category: category1)
      # グループ2にアイテム名が牛乳のアイテムを作成
      duplicate_item = build(:item, name: "牛乳", group: group2, category: category2)
      # グループ2に作成した同じ名前のアイテムが有効であるか確認
      expect(duplicate_item).to be_valid
    end

    it "アイテムとカテゴリーが別のグループに紐づく場合は無効であること" do
      # アイテムが紐づくグループを作成
      group_for_item = create(:group)
      # カテゴリーが紐づくグループを作成
      group_for_category = create(:group)
      # group_for_categoryに紐づくカテゴリーを作成
      category = create(:category, group: group_for_category)
      # カテゴリーが紐づくグループと別のグループに紐づくアイテムを作成
      invalid_item = build(:item, group: group_for_item, category: category)
      # 作成したアイテムが無効か確認
      expect(invalid_item).to be_invalid
    end
  end

  describe "アイテムのリレーションに関するテスト" do
    # 検証するアイテムを作成
    let(:item) { create(:item) }
    it "アイテムはグループに紐づいていること" do
      # 作成したアイテムにgroup_idが存在するか確認
      expect(item.group_id).to be_present
    end

    it "アイテムはカテゴリーに紐づいていること" do
      # 作成したアイテムにcategory_idが存在するか確認
      expect(item.category_id).to be_present
    end
  end
end
