class Item < ApplicationRecord
  # アイテムは1つのグループに紐づく
  belongs_to :group
  # アイテムは1つのカテゴリーに紐づく
  belongs_to :category
  # アイテムは1つののinventoryを持つ
  has_one :inventory
  # アイテム名必須 & 1文字以上12文字以下 & 同グループ内で固有
  validates :name, presence: true, length: { in: 1..12 }, uniqueness: { scope: :group_id }
  # アイテムが紐づくグループとカテゴリーが紐づくグループが同じかチェックする
  validate :category_belong_same_group
  # アイテム作成時に在庫も作成する
  after_create :create_inventory

  private

  def category_belong_same_group
    return if category.group_id == group_id
    errors.add(:category_id, "は同じグループのカテゴリーを選択してください。")
  end

  # アイテムの作成時に紐づく在庫の作成をする
  def create_inventory
    Inventory.find_or_create_by(group_id: group_id, item_id: id) do |inventory|
      inventory.quantity = 0
    end
  end
end
