require "rails_helper"

RSpec.describe "HomesController", type: :request do
  describe "GET #index" do
    it "トップページにアクセスするとHTTPステータス200が返ること" do
      get root_path
      expect(response).to have_http_status(200)
    end

    it "トップページに新規登録のリンクが含まれること" do
      get root_path
      expect(response.body).to include(new_user_registration_path)
    end

    it "トップページにログインのリンクが含まれること" do
      get root_path
      expect(response.body).to include(new_user_session_path)
    end

    it "トップページにゲストログインのリンクが含まれること" do
      get root_path
      expect(response.body).to include(users_guest_sign_in_path)
    end
  end
end
