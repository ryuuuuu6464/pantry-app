class DashboardsController < ApplicationController
  # 未ログインはログイン画面へ
  before_action :authenticate_user!
  def show
    # current_userの所属グループのメンバーを取り出す
    @group_users = current_user.group&.users
  end
end
