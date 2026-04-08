require "rails_helper"

RSpec.describe "アイテム機能に関するテスト", type: :system do
  # ユーザーを作成
  let(:user) { create(:user, password: "password", password_confirmation: "password") }
  # グループを作成
  let!(:group) { create(:group, is_guest: false) }
  # カテゴリを作成
  let!(:food_category) { create(:category, group: group, name: "食料品") }
  let!(:daily_category) { create(:category, group: group, name: "日用品") }
  let(:item) { create(:item, group: group, category: food_category, name: "ハンドソープ") }

  # ログイン
  def sign_in_as(user)
    visit new_user_session_path
    fill_in "user_email", with: user.email
    fill_in "user_password", with: "password"
    click_button "ログインする"
  end

  before do
    user.update!(group: group)
    sign_in_as(user)
  end

  it "アイテムを新規作成できること" do
    # アイテム作成画面にアクセス
    visit new_item_path

    # アイテム名を入力と、カテゴリを選択する
    fill_in "item_name", with: "牛乳"
    select "食料品", from: "item_category_id"

    # 作成ボタンを押してアイテムを作成
    click_button "作成する"

    # アイテムの作成後にアイテム一覧画面にリダイレクトされるか確認
    expect(current_path).to eq(items_path)
    # 作成したアイテムが一覧に表示されているか確認
    expect(page).to have_content("牛乳")
  end

  it "アイテム名を編集できること" do
    # アイテム編集画面にアクセス
    visit edit_item_path(item)

    # アイテム名を変更して保存する
    fill_in "item_name", with: "食器洗剤"
    click_button "保存"

    # 変更後にアイテム一覧画面にリダイレクトされるか確認
    expect(current_path).to eq(items_path)
    # アイテム一覧で名前が変更されて表示されているか確認
    expect(page).to have_content("食器洗剤")
  end

  it "アイテムのカテゴリを変更できること" do
    # アイテム編集画面にアクセス
    visit edit_item_path(item)

    # アイテムのカテゴリを変更して保存する
    select "日用品", from: "item_category_id"
    click_button "保存"

    # 変更後にアイテム一覧画面にリダイレクトされるか確認
    expect(current_path).to eq(items_path)
    # 対象のアイテムのカテゴリのDBレコードが更新されて日用品に変更されているか確認
    expect(item.reload.category).to eq(daily_category)
  end

  context "カテゴリ絞り込みに関するテスト" do
    let!(:milk) { create(:item, group: group, category: food_category, name: "牛乳") }
    let!(:handsoap) { create(:item, group: group, category: daily_category, name: "ハンドソープ") }

    before do
      # アイテム一覧画面にアクセス
      visit items_path
      # 食料品カテゴリを選択して絞り込む
      select "食料品", from: "category_id"
      click_button "絞り込む"
    end

    it "選択したカテゴリのアイテムが表示されること" do
      expect(page).to have_content("牛乳")
    end

    it "選択していないカテゴリのアイテムが表示されないこと" do
      expect(page).not_to have_content("ハンドソープ")
    end
  end

  context "在庫数の表示と増減に関するテスト" do
    # 在庫確認で使用するテストアイテムを作成
    let!(:stock_item) { create(:item, group: group, category: food_category, name: "テストアイテム") }

    before do
      # アイテム数の増減をテストするために在庫数を3にしておく
      stock_item.inventory.update!(quantity: 3)
      # アイテム一覧画面にアクセス
      visit items_path
    end

    it "現在の在庫数が画面に表示されること" do
      # テストアイテムの行に絞って在庫数の表示を確認
      within(".item-list-item", text: "テストアイテム") do
        # テストアイテムの在庫数3が表示されているか確認
        expect(page).to have_selector(".item-stock-value", text: "3")
      end
    end

    it "アイテムの在庫数を増やせること" do
      # テストアイテムの在庫を増やすボタンを押す
      within(".item-list-item", text: "テストアイテム") do
        click_button "+"
      end

      # テストアイテムの在庫数が3から4に増えていることを確認
      expect(stock_item.inventory.reload.quantity).to eq(4)
    end

    it "アイテムの在庫数を減らせること" do
      # テストアイテムの在庫を減らすボタンを押す
      within(".item-list-item", text: "テストアイテム") do
        click_button "-"
      end

      # テストアイテムの在庫数が3から2に減っていることを確認
      expect(stock_item.inventory.reload.quantity).to eq(2)
    end
  end
end
