class Inventory < ApplicationRecord
  # Inventoryは1つのグループに紐づく
  belongs_to :group
  # Inventoryは1つのアイテムに紐づく
  belongs_to :item
  # quantity必須 & 0以上の整数
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  # 同じグループ内でアイテムのinventoryは1つだけ
  validates :item_id, uniqueness: { scope: :group_id }
  # アイテムが紐づくグループとinventoryが紐づくグループが同じかチェックする
  validate :item_belong_same_group

  private

  def item_belong_same_group
    return if item.group_id == group_id
    errors.add(:item_id, "は同じグループのアイテムを選択してください。")
  end
end
