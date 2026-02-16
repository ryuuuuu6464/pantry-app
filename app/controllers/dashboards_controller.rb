class DashboardsController < ApplicationController
  # 未ログインはログイン画面へ
  before_action :authenticate_user!
  def show
  end
end
