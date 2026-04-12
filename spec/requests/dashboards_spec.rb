require "rails_helper"

RSpec.describe "DashboardsController", type: :request do
  describe "GET dashboards#show" do
    it "ダッシュボードにアクセスするとHTTPステータス200が返ること" do
      user = create(:user)
      post user_session_path, params: { user: { email: user.email, password: user.password } }
      get dashboard_path
      expect(response).to have_http_status(200)
    end
  end
end
