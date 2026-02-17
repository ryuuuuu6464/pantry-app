class GroupsController < ApplicationController
  before_action :authenticate_user!
  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params.require(:group).permit(:name))
    if @group.save
      current_user.update!(group: @group)
      redirect_to dashboard_path
    else
      render "new", status: :unprocessable_entity
    end
  end

  private

  # 1ユーザー1グループの制約
  def redirect_if_already_grouped
    # current_userがgroup_idを持っていなければ処理から抜ける
    return unless current_user.group_id.present?
    # すでにgroup_idを持っているのでダッシュボードに返す
    redirect_to dashboard_path, alert: "すでにグループに所属しています。"
  end
end
