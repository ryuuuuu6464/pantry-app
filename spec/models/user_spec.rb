require "rails_helper"

RSpec.describe User, type: :model do
  describe "ユーザーのバリデーションに関するテスト" do
    it "名前が無い場合は無効であること" do
      # 名前が空欄のユーザーを作成
      user_without_name = FactoryBot.build(:user, name: "")
      # 作成したユーザーが無効か確認
      expect(user_without_name).to be_invalid
    end

    it "名前が10文字以内の場合は有効であること" do
      # 名前が10文字のユーザーを作成
      user_less_than_name = FactoryBot.build(:user, name: "a" * 10)
      # 作成したユーザーが有効か確認
      expect(user_less_than_name).to be_valid
    end

    it "名前が11文字以上の場合は無効であること" do
      # 名前が11文字のユーザーを作成
      user_more_than_name = FactoryBot.build(:user, name: "a" * 11)
      # 作成したユーザーが無効か確認
      expect(user_more_than_name).to be_invalid
    end

    it "メールアドレスの重複を許さないこと" do
      # 1人目のユーザーを作成
      user = create(:user, email: "duplicate@example.com")
      # 2人目のユーザーを作成
      duplicate_user = FactoryBot.build(:user, email: "duplicate@example.com")
      # 2人目が無効か確認
      expect(duplicate_user).to be_invalid
      # emailにエラーが出るか確認
      expect(duplicate_user.errors[:email]).to be_present
    end
  end

  describe "ゲストユーザーに関するテスト" do
    it "ゲストユーザーを作成できること" do
      # ゲストユーザーを作成
      guest = User.guest
      # ゲスト用メールアドレスで作成されているか確認
      expect(guest.email).to eq("guest@example.com")
      # is_guestがtrueになっているか確認
      expect(guest.is_guest).to be(true)
    end

    it "ゲストを共通化できていること" do
      # ゲストを呼ぶ
      first_guest = User.guest
      # もう一度ゲストを呼ぶ
      second_guest = User.guest
      # 同じidであることを確認
      expect(second_guest.id).to eq(first_guest.id)
    end
  end
end
