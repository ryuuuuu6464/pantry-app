require "rails_helper"

RSpec.describe "ItemsController", type: :request do
  # テスト用ユーザーを作成
  let(:user) { create(:user) }
  # テスト用グループを作成
  let(:group) { create(:group) }
  # ユーザーの所属グループ紐づくカテゴリーを作成
  let(:category) { create(:category, group: group) }
  # ユーザーの所属グループに紐づくアイテムを作成
  let(:item) { create(:item, group: group, category: category) }

  # ユーザーをログインさせるメソッド
  def login_as(user)
    post user_session_path, params: { user: { email: user.email, password: user.password } }
  end

  describe "GET /items" do
    it "未ログイン時はログイン画面にリダイレクトされること" do
      # アイテム一覧へアクセスする
      get items_path
      # ログイン画面へリダイレクトされるか確認
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みグループ未所属の場合はダッシュボードにリダイレクトされること" do
      # ユーザーをログインさせる
      login_as(user)
      # アイテム一覧へアクセスする
      get items_path
      # ダッシュボードにリダイレクトされるか確認
      expect(response).to redirect_to(dashboard_path)
    end

    it "ログイン済みグループ所属の場合は正常にアイテム一覧ページにアクセスできること" do
      # ユーザーをグループに所属させる
      user.update!(group: group)
      # ユーザーをログインさせる
      login_as(user)
      # アイテム一覧へアクセスする
      get items_path
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

    describe "GET /items/new" do
      it "正常にアイテム新規作成画面にアクセスできること" do
        # アイテム新規作成画面へアクセスする
        get new_item_path
        # HTTPステータス200が返るか確認
        expect(response).to have_http_status(200)
      end
    end

    describe "POST /items" do
      it "アイテムを作成できること" do
        # アイテム名が「牛乳」のアイテムを作成
        post items_path, params: { item: { name: "牛乳", category_id: category.id } }
        # アイテム名が「牛乳」のアイテムが存在することを確認
        expect(Item.exists?(name: "牛乳", group_id: user.group_id, category_id: category.id)).to be(true)
      end

      it "作成したアイテムが作成者のグループに紐づくこと" do
        # アイテムを作成する
        post items_path, params: { item: { name: "牛乳", category_id: category.id } }
        # 最後に作成されたアイテムのgroup_idがユーザーのgroup_idと同じことを確認する
        expect(Item.last.group_id).to eq(user.group_id)
      end
    end

    describe "PATCH /items/:id" do
      it "アイテム名を更新できること" do
        patch item_path(item), params: { item: { name: "更新アイテム" } }
        # PATCHでアイテム名が更新アイテムに変わることを確認
        expect(item.reload.name).to eq("更新アイテム")
      end
    end

    describe "DELETE /items/:id" do
      it "アイテムを削除できること" do
        # 削除対象のアイテムを作成
        delete_item = create(:item, name: "削除アイテム", group_id: user.group_id, category_id: category.id)
        # 作成したアイテムを削除する
        delete item_path(delete_item)
        # アイテム名が「削除アイテム」のアイテムが存在しないことを確認
        expect(Item.exists?(name: "削除アイテム", group_id: user.group_id)).to be(false)
      end
    end
  end

  describe "他グループアイテムへのアクセス制限" do
    # 別グループを作成
    let(:other_group) { create(:group) }
    # 別グループのカテゴリーを作成
    let(:other_category) { create(:category, group: other_group) }
    # 別グループのアイテムを作成
    let(:other_group_item) { create(:item, group: other_group, category: other_category) }

    # ログイン済みグループ所属済みユーザーを定義
    before do
      user.update!(group: group)
      login_as(user)
    end

    it "他グループのアイテム編集画面にはアクセスできないこと" do
      # 他グループのアイテム編集画面へアクセスする
      get edit_item_path(other_group_item)
      # アイテム一覧へリダイレクトされるか確認
      expect(response).to redirect_to(items_path)
    end
  end
end
