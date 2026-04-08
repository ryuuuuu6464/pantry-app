require "rails_helper"

RSpec.describe "トップページに関するテスト", type: :system do
  # トップページにアクセス
  before do
    visit root_path
  end

  it "トップページに見出しが表示されること" do
    expect(page).to have_content("Pantryへようこそ")
  end

  it "トップページに新規登録リンクが表示されること" do
    expect(page).to have_link("新規登録", href: new_user_registration_path)
  end

  it "トップページにログインリンクが表示されること" do
    expect(page).to have_link("ログイン", href: new_user_session_path)
  end

  it "トップページにゲストログインリンクが表示されること" do
    expect(page).to have_link("ゲストログイン", href: users_guest_sign_in_path)
  end

  it "新規登録リンクから新規登録画面に遷移できること" do
    click_link "新規登録"
    expect(current_path).to eq(new_user_registration_path)
  end

  it "ログインリンクからログイン画面に遷移できること" do
    click_link "ログイン"
    expect(current_path).to eq(new_user_session_path)
  end

  # 以下のテストはSelenium環境を設定してからコメントアウトを外す

  # it "ゲストログインリンクを押したらログインしてダッシュボードに遷移すること" do
  #   click_link "ゲストログイン"
  #   expect(current_path).to eq(dashboard_path)
  # end
end
