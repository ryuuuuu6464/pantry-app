require "rails_helper"

RSpec.describe "CategoriesController", type: :request do
  # 一般ユーザーを作成する
  let(:user) { create(:user) }
  # グループを1つ作成
  let(:group) { create(:group) }
  # カテゴリーを1つ作成
  let(:category) { create(:category, group: group) }

  # リクエストスペック内で使うログインヘルパー
  def login_as(target_user)
    # DeviseのログインエンドポイントにPOSTしてセッションを作る
    post user_session_path, params: { user: { email: target_user.email, password: target_user.password } }
  end

  describe "GET /categories" do
    it "未ログイン時はログイン画面へリダイレクトされること" do
      # カテゴリー一覧へアクセスする
      get categories_path
      # ログイン画面にリダイレクトされるか確認
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みグループ未所属の場合はダッシュボードへリダイレクトされること" do
      # ユーザーをログインさせる
      login_as(user)
      # カテゴリー一覧へアクセスする
      get categories_path
      # ダッシュボードにリダイレクトされるか確認
      expect(response).to redirect_to(dashboard_path)
    end

    it "ログイン済みグループ所属済み時は正常にカテゴリー一覧にアクセスできること" do
      # ユーザーをグループに所属させる
      user.update!(group: group)
      # ユーザーをログインさせる
      login_as(user)
      # カテゴリー一覧へアクセスする
      get categories_path
      # HTTPステータス200が返るか確認
      expect(response).to have_http_status(200)
    end
  end

  context "ログイン済みグループ所属ユーザーのテスト" do
    # 事前にユーザーをログインさせてグループに所属させる
    before do
      user.update!(group: group)
      login_as(user)
    end

    describe "POST /categories" do
      it "カテゴリーを作成できること" do
        # カテゴリー名が「食料品」のカテゴリーを作成
        post categories_path, params: { category: { name: "食料品" } }
        # カテゴリー名が「食料品」のカテゴリーが存在することを確認
        expect(Category.exists?(name: "食料品", group_id: user.group_id)).to be(true)
      end

      it "作成したカテゴリーが作成者のグループに紐づくこと" do
        # カテゴリーを作成
        post categories_path, params: { category: { name: "日用品" } }
        # 作成したカテゴリーのgroup_idがユーザーのgroup_idと一致するか確認
        expect(Category.last.group_id).to eq(user.group_id)
      end
    end

    describe "PATCH /categories/:id" do
      it "カテゴリー名を更新できること" do
        # PATCHでnameが変わることを確認する
        patch category_path(category), params: { category: { name: "更新カテゴリー" } }
        expect(category.reload.name).to eq("更新カテゴリー")
      end
    end

    describe "DELETE /categories/:id" do
      it "カテゴリーを削除できること" do
        # カテゴリー名が「食料品」のカテゴリーを作成
        delete_category = create(:category, name: "食料品")
        # カテゴリー名が「食料品」のカテゴリーを削除
        delete category_path(delete_category)
        # カテゴリー名が「食料品」のカテゴリーが存在しないことを確認
        expect(Category.exists?(name: "食料品", group_id: user.group_id)).to be(false)
      end
    end
  end

  describe "他グループカテゴリへのアクセス制限" do
    # 別グループを作成する
    let(:other_group) { create(:group) }
    # 別グループのカテゴリを作成する
    let(:other_group_category) { create(:category, group: other_group) }
    # ログイン済みグループ所属済みユーザーを定義
    before do
      user.update!(group: group)
      login_as(user)
    end

    it "他グループのカテゴリ編集画面にはアクセスできないこと" do
      # 他グループカテゴリのeditにアクセスする
      get edit_category_path(other_group_category)
      # カテゴリー一覧へリダイレクトされることを確認
      expect(response).to redirect_to(categories_path)
    end
  end
end
