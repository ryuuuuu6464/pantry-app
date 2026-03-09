class GroupsController < ApplicationController
  # 未ログインは全アクション不可
  before_action :authenticate_user!
  # すでにグループに所属していたらグループの作成・参加は不可
  before_action :redirect_if_already_grouped, only: [ :new, :create, :join, :join_by_token ]
  # グループ未所属は脱退・グループ編集は不可
  before_action :redirect_if_still_grouped, only: [ :leave, :edit, :update ]
  # グループの編集前にユーザーのグループをセット
  before_action :set_current_group, only: [ :edit, :update ]
  # 新しいグループを作成
  def new
    @group = Group.new
  end

  # グループ作成で入力された情報を保存
  def create
    @group = Group.new(params.require(:group).permit(:name))
    # グループの作成者がゲストor一般ユーザーをセット
    @group.is_guest = current_user.is_guest
    if @group.save
      # 作成者のgroup_idを更新
      current_user.update!(group: @group)
      redirect_to dashboard_path, notice: "グループを作成しました。"
    else
      render "new", status: :unprocessable_entity
    end
  end

  def navigation
  end

  def join
  end

  def join_by_token
    # 入力された文字列を取り出す
    invite_token = params[:invite_token].to_s
    # invite_tokenが一致するグループを探す
    group = Group.find_by(invite_token: invite_token)
    # invite_tokenが一致する。かつ、is_guestが一致する時の処理
    if group.present? && same_user_type?(group)
      # current_userの所属グループを更新し、ダッシュボードに移動
      current_user.update!(group: group)
      redirect_to dashboard_path, notice: "グループに参加しました。"
    # invite_tokenが一致しないか、is_guestが一致しない時の処理
    else
      # フラッシュメッセージを表示して参加画面を表示
      flash[:alert] = "招待トークンが間違っているか、参加できないグループです。"
      render :join, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @group.update(params.require(:group).permit(:name))
      redirect_to dashboard_path, notice: "グループ名を更新しました。"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def leave
    # current_userのgroup_idをnilにしてグループ退会
    current_user.update!(group: nil)
    redirect_to dashboard_path, notice: "グループを退会しました。"
  end

  private

  # グループ所属判定メソッド
  def grouped_user?
    current_user.group_id.present?
  end

  # 所属済みが作成・参加しようとしたらリダイレクト
  def redirect_if_already_grouped
    # current_userにgroup_idがなければ処理から抜ける
    return unless grouped_user?
    # すでにgroup_idがあればダッシュボードに返す
    redirect_to dashboard_path, alert: "すでにグループに所属しています。"
  end

  # 未所属が脱退・グループ編集しようとしたらリダイレクト
  def redirect_if_still_grouped
    return if grouped_user?
    redirect_to navigation_group_path, alert: "まだグループに所属していません。"
  end

  # current_userとgroupのis_guestが同じか
  def same_user_type?(group)
    group.is_guest == current_user.is_guest
  end

  def set_current_group
    @group = current_user.group
  end
end
