class AccountsController < ApplicationController
  before_action :check_params
  before_action :auth_token, only: [:logout, :change_password, :change_avatar]
  after_action  :do_response

  def signup
    user = User.create_by_params(params)
    @status = ( user.save ? :ok : :error )
    @detail_data = { token: user.token }
  end

  def login
    user = User.find_by(name: params[:name])
    if user
      generate_hash = BCrypt::Engine.hash_secret(params[:password], user.password_salt)
      if user.password_hash == generate_hash
        user.set_token
        @status = :ok
        @detail_data = { token: user.token }
      else
        @status = :error
      end
    else
      @status = :error
    end
  end

  def logout
    current_user = User.find_by(name: params[:name])
    current_user.update(token: nil, token_created_at: nil, token_expired_at: nil)
    @status = :ok
  end

  def change_password
    current_user = User.find_by(name: params[:name])
    generate_hash = BCrypt::Engine.hash_secret(params[:old_password], current_user.password_salt)
    if current_user.password_hash == generate_hash
      current_user.update_password(params[:new_password])
      @status = :ok
    else
      @status = :error
    end
  end

  def get_avatar
    base64_identicon = RubyIdenticon.create_base64(params[:name] + DateTime.now.to_s)
    @status = :ok
    @detail_data = { avatar: base64_identicon }
  end

  def change_avatar
    current_user = User.find_by(name: params[:name])
    if params[:avatar].size >= CONFIG[:avatar_str_limit]
      @status = :error      
    else
      current_user.update(avatar: params[:avatar])
      @status = :ok
    end
  end

end
