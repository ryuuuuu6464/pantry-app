class GroupsController < ApplicationController
  # ログイン済みか？
  before_action :authenticate_user!
  # すでにグループに所属していないか？
  before_action :redirect_if_already_grouped, only: [ :new, :create, :join, :join_by_token ]
  # 新しいグループを作成
  def new
    @group = Group.new
  end

  # グループ作成で入力された情報を保存
  def create
    @group = Group.new(params.require(:group).permit(:name))
    if @group.save
      current_user.update!(group: @group)
      redirect_to dashboard_path, notice: "グループを作成しました。"
    else
      render "new", status: :unprocessable_entity
    end
  end

  def join
  end

  def join_by_token
    # 入力された文字列を取り出す
    invite_token = params[:invite_token].to_s
    # invite_tokenが一致するグループを探す
    group = Group.find_by(invite_token: invite_token)
    # invite_tokenが一致するグループが見つかった時の処理
    if group.present?
      # current_userの所属グループを更新し、ダッシュボードに移動
      current_user.update!(group: group)
      redirect_to dashboard_path, notice: "グループに参加しました。"
    # invite_tokenが一致するグループが見つからなかった時の処理
    else
      # フラッシュメッセージを表示して参加画面を表示
      flash[:alert] = "招待トークンが正しくありません。"
      render :join, status: :unprocessable_entity
    end
  end

  private

  # 1ユーザー1グループの制約
  def redirect_if_already_grouped
    # current_userにgroup_idがなければ処理から抜ける
    return unless current_user.group_id.present?
    # すでにgroup_idがあればダッシュボードに返す
    redirect_to dashboard_path, alert: "すでにグループに所属しています。"
  end
end
