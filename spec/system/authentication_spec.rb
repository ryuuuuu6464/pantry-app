require "rails_helper"

RSpec.describe "認証機能に関するシステムスペック", type: :system do
  # ログインとログアウト用の既存ユーザーを用意
  let(:user) { create(:user, password: "password", password_confirmation: "password") }

  context "フォームの入力値が正常" do
    it "ユーザーの新規登録が出来ること" do
      # 新規登録画面にアクセス
      visit new_user_registration_path

      # 入力欄に値を入力する
      fill_in "user_name", with: "山田 太郎"
      fill_in "user_email", with: "yamada_taro@example.com"
      fill_in "user_password", with: "password"
      fill_in "user_password_confirmation", with: "password"

      # 登録ボタンを押す
      click_button "アカウント登録"

      # 新規登録後にダッシュボードに遷移するか確認
      expect(current_path).to eq(dashboard_path)
      # 入力したメールアドレスのユーザーが存在するか確認
      expect(User.exists?(email: "yamada_taro@example.com")).to be(true)
    end

    it "ログインが出来ること" do
      # ログイン画面にアクセス
      visit new_user_session_path

      # 入力欄にメールアドレスとパスワードを入力
      fill_in "user_email", with: user.email
      fill_in "user_password", with: "password"

      # ログインボタンを押す
      click_button "ログインする"

      # ログイン後にダッシュボードに遷移するか確認
      expect(current_path).to eq(dashboard_path)
    end

    # 以下ログアウトのテストはSelenium環境を設定してからコメントアウトを外す。

    # it "ログアウトが出来ること" do
    #   # ログイン画面にアクセス
    #   visit new_user_session_path
    #   # ログイン情報を入力してログインする
    #   fill_in "user_email", with: user.email
    #   fill_in "user_password", with: "password"
    #   click_button "ログインする"
    #   # ログアウトリンクを押す
    #   click_link "ログアウト"
    #   # ログアウト後にroot_pathに遷移するか確認
    #   expect(current_path).to eq(root_path)
    # end
  end
end
