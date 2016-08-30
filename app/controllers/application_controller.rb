class ApplicationController < ActionController::API
  # use respond_to
  include ActionController::MimeResponds
  # disable the CSRF token
  skip_before_action :verify_authenticity_token

  def check_params
    params_error = case params[:action].to_sym
    when :signup, :login
      params[:name].blank? || params[:password].blank?
    when :logout, :check_data, :push_data, :pull_data, :sync_data
      params[:name].blank? || params[:token].blank?
    when :change_password
      params[:name].blank? || params[:token].blank? || params[:old_password].blank? || params[:new_password].blank?
    when :get_avatar
      params[:name].blank?
    when :change_avatar
      params[:name].blank? || params[:token].blank? || params[:avatar].blank?
    else
      true
    end

    if params_error
      respond_to do |format|
        format.json { render json: Response.params_error }
      end
    end
  end

  def auth_token
    user = User.find_by(name: params[:name], token: params[:token])
    auth_ok = (user && (user.token_expired_at > DateTime.now))

    unless auth_ok
      respond_to do |format|
        format.json { render json: Response.token_error }
      end
    end
  end

  def do_response
    respond_to do |format|
      format.json { render json: Response.build_response(params[:action].to_sym, @status.to_s, @detail_data ||= {}) }
    end
  end

end
