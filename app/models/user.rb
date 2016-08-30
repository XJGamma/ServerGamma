class User < ActiveRecord::Base
  validates :name, uniqueness: true
  has_many :user_data

  def self.create_by_params(params)
    user = User.new(name: params[:name])
    user.password_salt = BCrypt::Engine.generate_salt
    user.password_hash = BCrypt::Engine.hash_secret(params[:password], user.password_salt)
    user.set_token

    user
  end

  def set_token
    self.token = SecureRandom.hex
    self.token_created_at = DateTime.now
    self.token_expired_at = CONFIG[:token_life_time].days.from_now

    save
  end

  def update_password(new_password)
    self.password_hash = BCrypt::Engine.hash_secret(new_password, self.password_salt)

    save
  end

end
