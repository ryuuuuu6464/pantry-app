require "rails_helper"

RSpec.describe Group, type: :model do
  describe "グループのバリデーションに関するテスト" do
    it "名前がない場合は無効であること" do
      # グループ名が空欄のグループを作成
      group_without_name = FactoryBot.build(:group, name: "")
      # 作成したグループが無効か確認
      expect(group_without_name).to be_invalid
    end

    it "グループ名が12文字以下の場合は有効であること" do
      # グループ名が12文字のグループを作成
      group_less_than_name = FactoryBot.build(:group, name: "a" * 12)
      # 作成したグループが有効か確認
      expect(group_less_than_name).to be_valid
    end

    it "グループ名が13文字以上の場合は無効であること" do
      # グループ名が13文字のグループを作成
      group_more_than_name = FactoryBot.build(:group, name: "a" * 13)
      # 作成したグループが無効か確認
      expect(group_more_than_name).to be_invalid
    end

    it "is_guestがnilだと無効であること" do
      # is_guestがnilのグループを作成
      group_is_guest_nil = FactoryBot.build(:group, is_guest: nil)
      # 作成したグループが無効か確認
      expect(group_is_guest_nil).to be_invalid
    end

    it "招待トークン重複時に無効であること" do
      # 24文字の招待トークンを持ったグループを作成し、テストDBに保存
      group = create(:group, invite_token: "a" * 24)
      # 重複する招待トークンを持ったグループを作成
      duplicate_group = FactoryBot.build(:group, invite_token: "a" * 24)
      # 重複する招待トークンを持ったグループが無効か確認
      expect(duplicate_group).to be_invalid
      # グループ名にエラーが出ているか確認
      expect(duplicate_group.errors[:invite_token]).to be_present
    end
  end

  describe "招待トークン自動生成に関するテスト" do
    it "グループ作成時に招待トークンが自動生成されること" do
      # グループを作成し、テストDBに保存
      group = create(:group)
      # 招待トークンが存在するか確認
      expect(group.invite_token).to be_present
      # 招待トークンが24文字か確認
      expect(group.invite_token.length).to eq(24)
    end
  end
end
