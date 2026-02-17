class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 1ユーザーは1グループに所属（未所属でも可）
  belongs_to :group, optional: true
  # ゲストユーザー
  def self.guest
    find_or_create_by(email: "guest@example.com") do |user|
      user.name = "guestuser"
      user.password = SecureRandom.urlsafe_base64
      user.is_guest = true
    end
  end
end
