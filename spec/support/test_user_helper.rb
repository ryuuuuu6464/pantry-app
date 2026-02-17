module TestUserHelper
  def guest_user
    User.find_or_create_by(email: "guest@example.com") do |user|
      user.name = "guestuser"
      user.password = "password"
      user.is_guest = true
    end
  end
end
