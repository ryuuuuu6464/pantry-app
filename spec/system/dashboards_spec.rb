require "rails_helper"

RSpec.describe "ダッシュボードに関するテスト", type: :system do
  # ログインユーザーを作成
  let!(:user) { create(:user, password: "password", password_confirmation: "password") }

  # ログインメソッド
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password"
    click_button "ログインする"
  end

  context "グループ所属ユーザーの場合" do
    # グループを作成
    let!(:group) { create(:group, name: "テストグループ", is_guest: false) }

    # グループに所属してログインする
    before do
      user.update!(group: group)
      sign_in_as(user)
    end

    it "所属グループ名が表示されること" do
      expect(page).to have_content("所属グループ名: テストグループ")
    end

    it "所属グループの招待トークンが表示されること" do
      expect(page).to have_content("招待トークン:")
    end

    it "所属グループに所属しているユーザー名が表示されること" do
      expect(page).to have_content(user.name)
    end
  end

  context "グループ未所属ユーザーの場合" do
    # グループ未所属でログイン
    before do
      sign_in_as(user)
      visit dashboard_path
    end

    it "グループ未所属用のメッセージが表示されること" do
      expect(page).to have_content("グループの作成か参加をしてください。")
    end

    it "グループ作成リンクが表示されること" do
      expect(page).to have_link("グループを作成", href: new_group_path)
    end

    it "グループ参加リンクが表示されること" do
      expect(page).to have_link("グループに参加", href: join_group_path)
    end
  end
end
