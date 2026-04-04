class ItemsController < ApplicationController
  # 未ログインは全アクション不可
  before_action :authenticate_user!
  # グループ未所属ユーザーは全アクション不可
  before_action :ensure_user_has_group!
  # 他グループのアイテム操作を制限
  before_action :authorize_item_group!, only: [ :show, :edit, :update, :destroy ]
  # フォーム用のカテゴリー一覧を取得
  before_action :set_categories, only: [ :new, :create, :edit, :update ]
  # itemが見つからないときのエラーハンドリング
  rescue_from ActiveRecord::RecordNotFound, with: :item_not_found

  # アイテム一覧を表示
  def index
    # 絞り込み用にカテゴリーを取得
    @categories = current_user.group.categories.order(:id)
    # 自分のグループのアイテムを取得(カテゴリをincludesで先読みしてN+1を防ぐ)
    @items = current_user.group.items.includes(:category)
    # category_idが送られてきたら絞り込み
    if params[:category_id].present?
      @items = @items.where(category_id: params[:category_id])
    end
    # ログイン中ユーザーのグループの在庫一覧を取得し、item_idを在庫レコードの形のhashに変換する(viewで@inventories[item.id]として参照しやすくするため)
    @inventories = current_user.group.inventories.index_by(&:item_id)
  end

  # アイテム新規作成画面を表示
  def new
    # 空のItemインスタンスを作る
    @item = Item.new
  end

  # アイテム新規作成の処理
  def create
    # アイテムの紐づくグループをcurrent_userが所属するグループにする
    @item = current_user.group.items.new(params.require(:item).permit(:name, :category_id))
    # 保存した時
    if @item.save
      # アイテム一覧にリダイレクト
      redirect_to items_path, notice: "アイテムを作成しました。"
    else
      # 失敗したらアイテム作成画面を再表示
      render :new, status: :unprocessable_entity
    end
  end

  # アイテム詳細を表示
  def show
  end

  # アイテム編集画面を表示
  def edit
  end

  # アイテム更新の処理
  def update
    # アイテム更新が成功した時
    if @item.update(params.require(:item).permit(:name, :category_id))
      # アイテム一覧にリダイレクト
      redirect_to items_path, notice: "アイテムを更新しました。"
    else
      # 失敗したら編集画面を再表示
      render :edit, status: :unprocessable_entity
    end
  end

  # アイテム削除の処理
  def destroy
    # 取得したアイテムを削除
    @item.destroy
    # 削除後はアイテム一覧にリダイレクト
    redirect_to items_path, notice: "アイテムを削除しました。"
  end

  private

  def set_categories
    # 自分のグループのカテゴリーをid順で取得
    @categories = current_user.group.categories.order(:id)
  end

  # ユーザーがグループ所属か確認する
  def ensure_user_has_group!
    # group_idがあれば処理を続ける
    return if current_user.group_id.present?
    # group_idが無ければダッシュボードにリダイレクト
    redirect_to dashboard_path, alert: "グループに所属していません。"
  end

  # itemが自分のグループ所属か確認する
  def authorize_item_group!
    # 対象itemを取得
    @item = Item.find(params[:id])
    # 同じグループなら処理を続ける
    return if @item.group_id == current_user.group_id
    # 違うグループならアイテム一覧にリダイレクト
    redirect_to items_path, alert: "このアイテムにはアクセスできません。"
  end

  # itemが見つからなかった時の処理
  def item_not_found
    # エラーメッセージを表示してアイテム一覧にリダイレクト
    redirect_to items_path, alert: "そのアイテムは存在しません。"
  end
end
