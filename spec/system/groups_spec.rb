require "rails_helper"

RSpec.describe "グループ機能", type: :system do
  # すべてのテストで使うログインユーザー
  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  # 画面からログインする共通処理
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password"
    click_button "ログインする"
  end

  context "グループ未所属ユーザー" do
    # 参加先グループを事前作成
    let!(:target_group) { create(:group, name: "テストグループ", is_guest: false) }

    it "グループを作成できること" do
      # ログイン
      sign_in_as(user)

      # グループ作成画面にアクセス
      visit new_group_path

      # グループ名を入力して作成
      fill_in "group_name", with: "テストグループ"
      click_button "作成"

      # ダッシュボードに戻り、所属グループ名が表示されることを確認
      expect(current_path).to eq dashboard_path
      expect(page).to have_content("所属グループ名: テストグループ")
    end

    it "招待トークンでグループに参加できること" do
      # ログイン
      sign_in_as(user)

      # 参加画面にアクセス
      visit join_group_path

      # 招待トークンを入力して参加
      fill_in "invite_token", with: target_group.invite_token
      click_button "参加する"

      # ダッシュボードで参加できたことを確認
      expect(current_path).to eq dashboard_path
      expect(page).to have_content("所属グループ名: テストグループ")
    end
  end

  context "グループ所属ユーザー" do
    # グループの作成
    let!(:group) { create(:group, name: "編集前グループ", is_guest: false) }

    before do
      # ユーザーをグループに所属させる
      user.update!(group: group)
    end

    it "グループ名を編集できること" do
      # ログインしてグループ編集画面にアクセス
      sign_in_as(user)
      visit edit_group_path

      # グループ名を「編集後グループ」という名前に編集して保存
      fill_in "group_name", with: "編集後グループ"
      click_button "保存"

      # グループ名を編集後にダッシュボードに遷移するか確認
      expect(current_path).to eq dashboard_path
      # グループ名が「編集後グループ」に名前が変更されている確認
      expect(page).to have_content("所属グループ名: 編集後グループ")
    end
  end
end
