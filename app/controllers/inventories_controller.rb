class InventoriesController < ApplicationController
  # 未ログインは全アクション不可
  before_action :authenticate_user!
  # グループ未所属ユーザーは全アクション不可
  before_action :ensure_user_has_group!
  # 他グループの在庫操作を制限
  before_action :authorize_inventory_group, only: [ :update ]
  # inventoryが見つからない時のエラーハンドリング
  rescue_from ActiveRecord::RecordNotFound, with: :inventory_not_found

  def update
    if @inventory.update(params.require(:inventory).permit(:quantity))
      redirect_to items_path, notice: "在庫数を更新しました。"
    else
      redirect_to items_path, alert: @inventory.errors.full_messages.join(",")
    end
  end

  private

  # ユーザーがグループ所属済みか確認する
  def ensure_user_has_group!
    # 所属済みなら処理続行
    return if current_user.group_id.present?
    # 未所属ならダッシュボードへ戻す
    redirect_to dashboard_path, alert: "グループに所属していません。"
  end

  # ユーザーのgroup_idと更新するinventoryのgroup_idが違う場合はリダイレクト
  def authorize_inventory_group
    @inventory = Inventory.find(params[:id])
    return if @inventory.group_id == current_user.group_id
    redirect_to items_path, alert: "この在庫は操作できません。"
  end

  # 在庫が見つからない時の処理
  def inventory_not_found
    # 一覧へ戻してエラーメッセージを表示する
    redirect_to items_path, alert: "その在庫は存在しません。"
  end
end
