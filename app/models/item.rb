class Item < ApplicationRecord
  # アイテムは1つのグループに紐づく
  belongs_to :group
  # アイテムは1つのカテゴリーに紐づく
  belongs_to :category
  # アイテムは複数のinventoryを持つ
  has_many :inventories
  # アイテム名必須 & 1文字以上12文字以下 & 同グループ内で固有
  validates :name, presence: true, length: { in: 1..12 }, uniqueness: { scope: :group_id }
  # アイテムが紐づくグループとカテゴリーが紐づくグループが同じかチェックする
  validate :category_belong_same_group

  private

  def category_belong_same_group
    return if category.group_id == group_id
    errors.add(:category_id, "は同じグループのカテゴリーを選択してください。")
  end
end
