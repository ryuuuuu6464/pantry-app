require "rails_helper"

RSpec.describe "InventoriesController", type: :request do
  # テスト用ユーザーを作成
  let(:user) { create(:user) }
  # テスト用グループを作成
  let(:group) { create(:group) }
  # groupに紐づくカテゴリーを作成
  let(:category) { create(:category, group: group) }
  # groupに紐づくitemを作成
  let(:item) { create(:item, group: group, category: category) }
  # itemに紐づくinventoryを取得
  let(:inventory) { item.inventory }

  # ログインメソッド
  def login_as(user)
    post user_session_path, params: { user: { email: user.email, password: user.password } }
  end

  describe "PATCH /inventories/:id" do
    it "未ログイン時はログイン画面へリダイレクトされること" do
      # 在庫更新リクエストを送る
      patch inventory_path(inventory), params: { inventory: { quantity: 1 } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "ログイン済みグループ未所属時はダッシュボードへリダイレクトされること" do
      login_as(user)
      patch inventory_path(inventory), params: { inventory: { quantity: 1 } }
      expect(response).to redirect_to(dashboard_path)
    end

    context "ログイン済みグループ所属ユーザーの場合" do
      before do
        user.update!(group: group)
        login_as(user)
      end

      it "在庫数を更新できること" do
        patch inventory_path(inventory), params: { inventory: { quantity: 2 } }
        # 在庫数更新後はアイテム一覧にリダイレクト
        expect(response).to redirect_to(items_path)
        # 在庫数が2に更新出来ているかを確認
        expect(inventory.reload.quantity).to eq(2)
      end
    end
  end

  describe "他グループ在庫へのアクセス制限に関するテスト" do
    # 別グループの作成
    let(:other_group) { create(:group) }
    # 別グループのカテゴリーを作成
    let(:other_category) { create(:category, group: other_group) }
    # 別グループのアイテムを作成
    let(:other_item) { create(:item, group: other_group, category: other_category) }
    # 別グループのinventoryを取得
    let(:other_inventory) { other_item.inventory }

    # グループ所属とログインのメソッド
    before do
      user.update!(group: group)
      login_as(user)
    end

    it "他グループの在庫は更新できずitems一覧へリダイレクトされること" do
      # 別グループの在庫更新リクエストを送る
      patch inventory_path(other_inventory), params: { inventory: { quantity: 3 } }
      # 別グループの在庫数が更新されていないか確認
      expect(other_inventory.reload.quantity).to eq(0)
    end
  end

  describe "存在しないinventoryの更新に関するテスト" do
    before do
      user.update!(group: group)
      login_as(user)
    end

    it "存在しないinventory_idの場合はアイテム一覧へリダイレクトされること" do
      # 存在しないIDで更新リクエストを送る
      patch inventory_path(-1), params: { inventory: { quantity: 1 } }
      # アイテム一覧へリダイレクトされるか確認
      expect(response).to redirect_to(items_path)
    end
  end
end
