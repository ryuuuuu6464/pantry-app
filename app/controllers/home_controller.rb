class HomeController < ApplicationController
  # 未ログインはログイン画面へ飛ばす
  before_action :authenticate_user!

  def index
  end
end
