require "rails_helper"

RSpec.describe "UsersController", type: :request do
  describe "新規登録" do
    # 新規ユーザーのテストデータを用意
    let(:new_user) { attributes_for(:user) }
    it "正しい入力で新規登録できること" do
      # 新規ユーザーの情報を新規登録
      post user_registration_path, params: { user: new_user }
      # 新規登録後にダッシュボードへ遷移できることを確認
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "ログイン" do
    it "正しい入力でログインできること" do
      # ログインするユーザーをテストDBに保存
      user = create(:user, email: "login@example.com")
      # ログインするユーザーの情報を送る
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      # ログイン後にダッシュボードへ遷移できることを確認
      expect(response).to redirect_to(dashboard_path)
    end
  end

  describe "ゲストログイン" do
    it "ゲストログインができること" do
      # ゲストログインのHTTPリクエストを送る
      post users_guest_sign_in_path
      # ゲストログイン後にダッシュボードへ遷移できることを確認
      expect(response).to redirect_to(dashboard_path)
    end

    it "ゲストログインで正しくゲストユーザーが作成されていること" do
      # ゲストログインのHTTPリクエストを送る
      post users_guest_sign_in_path
      # ゲストユーザーを取得
      guest = User.find_by(email: "guest@example.com")
      # ゲストユーザーが存在するか確認
      expect(guest).to be_present
      # ゲストユーザーのis_guestがtrueであることを確認
      expect(guest.is_guest).to be(true)
    end
  end

  describe "ログアウト" do
    # ログアウトするユーザーを定義
    let(:logout_user) { create(:user, email: "logout@example.com") }
    it "ログアウトできること" do
      # ログインする
      post user_session_path, params: { user: { email: logout_user.email, password: logout_user.password } }
      # ログアウトする
      delete destroy_user_session_path
      # トップページに遷移するか確認
      expect(response).to redirect_to(root_path)
    end

    it "ログアウト後はダッシュボードにアクセスできないこと" do
      # ログインする
      post user_session_path, params: { user: { email: logout_user.email, password: logout_user.password } }
      # ログアウトする
      delete destroy_user_session_path
      # ログアウト後にダッシュボードへ遷移できないことを確認
      get dashboard_path
      # ログイン後にダッシュボードへアクセスしたらログインに遷移するか確認
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
