class Category < ApplicationRecord
  # 1つのグループに複数のカテゴリーが紐づく
  belongs_to :group
  # カテゴリー名必須 & 1文字以上12文字以下 & 同グループ内で固有
  validates :name, presence: true, length: { in: 1..12 }, uniqueness: { scope: :group_id }
end
