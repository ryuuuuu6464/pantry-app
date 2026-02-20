class Group < ApplicationRecord
  # 1つのグループは複数のユーザーを持つ
  has_many :users
  # 1つのグループは複数のカテゴリーを持つ
  has_many :categories
  # 1つのグループは複数のアイテムを持つ
  has_many :items
  # 1つのグループは複数の在庫を持つ
  has_many :inventories
  # Groupモデルのバリデーション
  # グループ作成時に招待トークンを生成
  before_validation :set_invite_token, on: :create
  # invite_token必須 & 固有
  validates :invite_token, presence: true, uniqueness: true
  # グループ名必須 & 1文字以上12文字以下
  validates :name, presence: true, length: { in: 1..12 }
  # is_guestがnilでない
  validates :is_guest, inclusion: { in: [ true, false ] }

  private

  # invite_tokenの自動作成
  def set_invite_token
    return if invite_token.present?
    # 重複避けるまでinvite_tokenを再生成
    loop do
      # 24文字のランダムな文字列をセット
      self.invite_token = SecureRandom.alphanumeric(24)
      # セットした招待トークンが既に存在しなければループから抜ける
      break unless Group.exists?(invite_token: invite_token)
    end
  end
end
