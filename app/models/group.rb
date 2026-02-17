class Group < ApplicationRecord
  # 1つのグループに複数のユーザー所属
  has_many :users

  before_validation :set_invite_token, on: :create
  # invite_tokenが作成されているか確認
  validates :invite_token, presence: true, uniqueness: true

  private

  # invite_tokenの自動作成
  def set_invite_token
    return if invite_token.present?
    # 重複避けるまでinvite_tokenを再生成
    loop do
      self.invite_token = SecureRandom.alphanumeric(24)
      break unless Group.exists?(invite_token: invite_token)
    end
  end
end
