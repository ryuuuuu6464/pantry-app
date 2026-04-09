require "rails_helper"

RSpec.describe "カテゴリ機能に関するテスト", type: :system do
  # ログイン用ユーザーを用意
  let(:user) { create(:user, password: "password", password_confirmation: "password") }
  # ユーザーが所属するグループを用意
  let!(:group) { create(:group, is_guest: false) }
  let(:category) { create(:category, group: group, name: "編集前カテゴリ") }

  # 画面操作でログインする共通処理
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password"
    click_button "ログインする"
  end

  before do
    # ユーザーをグループに所属させる
    user.update!(group: group)
    sign_in_as(user)
  end

  it "カテゴリを新規作成できること" do
    # カテゴリ作成画面にアクセス
    visit new_category_path

    # カテゴリ名を入力して作成
    fill_in "category_name", with: "食料品"
    click_button "作成する"

    # カテゴリ一覧画面にリダイレクトされるか確認
    expect(current_path).to eq(categories_path)
    # 作成したカテゴリ名が表示されているか確認
    expect(page).to have_content("食料品")
  end

  it "カテゴリ名を編集できること" do
    # カテゴリ編集画面にアクセス
    visit edit_category_path(category)

    # カテゴリ名を変更して保存
    fill_in "category_name", with: "編集後カテゴリ"
    click_button "保存"

    # カテゴリ一覧にリダイレクトされるか確認
    expect(current_path).to eq(categories_path)
    # カテゴリ名が変更されて表示されているか確認
    expect(page).to have_content("編集後カテゴリ")
  end
end
