require "rails_helper"

RSpec.describe Inventory, type: :model do
  describe "在庫のバリデーションに関するテスト" do
    # アイテムをテスト用に作成
    let(:item) { create(:item) }
    # 作成したテストアイテムに紐づくinventoryを用意
    let(:inventory) { item.inventory }

    it "在庫数が0の場合は有効であること" do
      expect(inventory).to be_valid
    end

    it "在庫数がマイナスの場合は無効であること" do
      # inventoryのquauntityをマイナスにする
      inventory.quantity = -1
      expect(inventory).to be_invalid
    end

    it "在庫数が整数でない場合は無効であること" do
      # inventoryのquantityを少数にする
      inventory.quantity = 1.5
      expect(inventory).to be_invalid
    end
  end

  describe "在庫のリレーションに関するテスト" do
    let(:item) { create(:item) }
    let(:inventory) { item.inventory }

    it "在庫はグループに紐づいていること" do
      expect(inventory.group_id).to be_present
    end

    it "在庫はアイテムに紐づいていること" do
      expect(inventory.item_id).to be_present
    end
  end
end
