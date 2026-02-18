require "rails_helper"

RSpec.describe "GroupsController", type: :request do
  # ユーザーをテストDBに作成
  let(:user) { create(:user) }
  # ゲストユーザーをテストDBに作成
  let(:guest_user) { create(:user, name: "guestuser", email: "guest@example.com", is_guest: true) }
  # グループを事前作成する
  let!(:group) { create(:group) }

  # ログイン処理を共通化するヘルパーメソッド
  def login_as(target_user, password: "password")
    post user_session_path, params: { user: { email: target_user.email, password: password } }
  end

  describe "GET /group/new" do
    context "未ログイン時" do
      it "ログイン画面へリダイレクトされること" do
        # グループ作成画面にアクセス
        get new_group_path
        # ログイン画面へリダイレクトされることを確認
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "ログイン済みかつ未所属時" do
      # ユーザーをログインさせる
      before { login_as(user) }

      it "グループ作成画面が正常に表示できること" do
        # グループ作成画面にアクセス
        get new_group_path
        # HTTPステータスが200で返ることを確認
        expect(response).to have_http_status(200)
      end
    end

    context "ログイン済みかつ所属済み時" do
      before do
        # ユーザーをログインさせる
        login_as(user)
        # 定義したグループに所属する
        user.update!(group: group)
      end

      it "すでにグループに所属しているユーザーはダッシュボードへリダイレクトされること" do
        # グループ作成画面にアクセス
        get new_group_path
        # ダッシュボードへリダイレクトされることを確認
        expect(response).to redirect_to(dashboard_path)
      end
    end
  end

  describe "POST /group" do
    let(:group_params) { { group: { name: "テストグループ" } } }

    context "ログイン済みかつ未所属時" do
      # ユーザーをログインさせる
      before { login_as(user) }

      it "Groupが1件増えること" do
        # POST実行で件数が1増えることを確認
        expect { post group_path, params: group_params }.to change(Group, :count).by(1)
      end

      it "作成者が作成グループに所属すること" do
        # グループを作成
        post group_path, params: group_params
        # userのgroup_idがnilでなくなることを確認
        expect(user.reload.group_id).to be_present
      end

      it "作成グループのis_guestが作成者と一致すること" do
        # グループを作成
        post group_path, params: group_params
        # 作成グループのis_guestが作成者と同じであることを確認
        expect(user.reload.group.is_guest).to eq(user.is_guest)
      end
    end
  end

  describe "PATCH /group/join" do
    # ユーザーをログインさせる
    before { login_as(user) }

    it "招待トークン一致かつis_guest一致で参加できること" do
      # グループ参加でgroup_idがnilから対象group.idに変わることを確認
      expect {
        patch join_group_path, params: { invite_token: group.invite_token }
      }.to change { user.reload.group_id }.from(nil).to(group.id)
    end

    it "間違ったトークンではグループに参加できないこと" do
      # 存在しないトークンで参加を実行
      patch join_group_path, params: { invite_token: "invalid_token" }
      # 422で返ることを確認
      expect(response).to have_http_status(:unprocessable_entity)
    end

    context "is_guest不一致の場合" do
      # ゲストグループを作成
      let!(:guest_group) { create(:group, :guest) }

      it "ユーザーがis_guest不一致でグループに参加できず、group_idがnilのままであること" do
        # 一般ユーザーがゲストグループの招待トークンでPATCH実行
        patch join_group_path, params: { invite_token: guest_group.invite_token }
        # 参加実行してもgroup_idが変わらないことを確認
        expect(user.reload.group_id).to be_nil
      end

      context "ゲストユーザーの場合" do
        # ゲストユーザーでログイン
        before { login_as(guest_user) }

        it "ゲストがis_guest不一致でグループに参加できず、group_idがnilのままであること" do
          # ゲストユーザーが一般ユーザーグループの招待トークンでPATCH実行
          patch join_group_path, params: { invite_token: group.invite_token }
          # 参加実行してもgroup_idが変わらないことを確認
          expect(guest_user.reload.group_id).to be_nil
        end
      end
    end
  end

  describe "DELETE /group/leave" do
    before do
      # ユーザーをログインさせる
      login_as(user)
      # グループに所属させる
      user.update!(group: group)
    end

    it "グループを退会するとgroup_idがnilになること" do
      # DELETE実行でgroup_idがgroup.idからnilへ変わることを確認
      expect { delete leave_group_path }.to change { user.reload.group_id }.from(group.id).to(nil)
    end
  end

  describe "PATCH /group" do
    # 所属先グループを事前作成する
    let!(:group) { create(:group, name: "変更前") }

    before do
      # ユーザーをログインさせる
      login_as(user)
      # グループに所属させる
      user.update!(group: group)
    end

    it "グループ名を更新できること" do
      # PATCH実行でnameが変わることを確認
      expect {
        patch group_path, params: { group: { name: "変更後" } }
      }.to change { group.reload.name }.from("変更前").to("変更後")
    end
  end
end
