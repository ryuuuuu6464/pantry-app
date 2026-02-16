class HomesController < ApplicationController
  def index
  end

  # ゲストログインメソッド
  def new_guest
    user = User.find_or_create_by(email: "guest@example.com") do |user|
      user.name = "guestuser"
      user.password = SecureRandom.urlsafe_base64
    end
    sign_in user
    redirect_to root_path, notice: "ゲストユーザーとしてログインしました。"
  end
end
