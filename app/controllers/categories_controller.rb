class CategoriesController < ApplicationController
  # 未ログインは全アクション不可
  before_action :authenticate_user!
  # グループ未所属ユーザーは全アクション不可
  before_action :ensure_user_has_group!
  # 他グループのカテゴリー操作を制限
  before_action :authorize_category_group!, only: [ :show, :edit, :update, :destroy ]
  # カテゴリーが見つからないときのエラーハンドリング
  rescue_from ActiveRecord::RecordNotFound, with: :category_not_found

  # カテゴリー一覧を表示
  def index
    # current_userの所属グループに紐づくカテゴリーを取得
    @categories = current_user.group.categories.all
  end

  # カテゴリー新規作成画面を表示
  def new
    # 新しいインスタンスを用意
    @category = Category.new
  end

  # カテゴリー新規作成の処理
  def create
    # カテゴリーをcurrent_userのグループに紐づけて作成
    @category = current_user.group.categories.new(params.require(:category).permit(:name))
    # 保存した時
    if @category.save
      # カテゴリー一覧にリダイレクト
      redirect_to categories_path, notice: "カテゴリーを作成しました。"
    else
      # 失敗したら作成画面を再表示
      render :new, status: :unprocessable_entity
    end
  end

  # カテゴリー詳細を表示
  def show
    # 詳細を表示するカテゴリーを取得
    @category = Category.find(params[:id])
  end

  # カテゴリー編集画面を表示
  def edit
    # 編集するカテゴリーを取得
    @category = Category.find(params[:id])
  end

  # カテゴリー更新の処理
  def update
    # 更新するカテゴリーを取得
    @category = Category.find(params[:id])
    # カテゴリー更新が成功した時
    if @category.update(params.require(:category).permit(:name))
      # カテゴリー一覧にリダイレクト
      redirect_to categories_path, notice: "カテゴリーを更新しました。"
    else
      # 失敗したら編集画面を再表示
      render :edit, status: :unprocessable_entity
    end
  end

  # カテゴリー削除の処理
  def destroy
    # 削除するカテゴリーを取得
    @category = Category.find(params[:id])
    # 削除処理
    @category.destroy
    # 削除後はカテゴリー一覧にリダイレクト
    redirect_to categories_path, notice: "カテゴリーを削除しました。"
  end

  private

  # ユーザーのグループ所属をチェック
  def ensure_user_has_group!
    # group_idがあれば処理を続ける
    return if current_user.group_id.present?
    # group_idが無ければダッシュボードにリダイレクト
    redirect_to dashboard_path, alert: "グループに所属していません。"
  end

  # current_userの所属するグループのカテゴリーかチェック
  def authorize_category_group!
    @category = Category.find(params[:id])
    # current_userのgroup_idと、カテゴリーのgroup_idが同じなら処理を続ける
    return if @category.group_id == current_user.group_id
    # current_userの所属するグループのカテゴリーでないので、リダイレクト
    redirect_to categories_path, alert: "このカテゴリーにはアクセスできません。"
  end

  # カテゴリーが存在しないエラー時の処理
  def category_not_found
    redirect_to categories_path, alert: "そのカテゴリーは存在しません。"
  end
end
