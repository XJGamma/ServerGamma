class DataController < ApplicationController
  before_action :check_params
  before_action :auth_token
  after_action  :do_response
  
  def check_data(sync_data=false)
    p params
    @check_list = (params[:check_list] ||= [])
    current_user = User.find_by(name: params[:name])
    @server_list = current_user.user_data.collect{ |user_data| { created_at: user_data.created_at, updated_at: user_data.updated_at } }
    p @server_list
    
    @detail_data = { 
      push_list: get_push_list,
      pull_list: get_pull_list(sync_data)
    }
    @status = :ok
  end

  def push_data
    data_list = (params[:list] ||= [])
    current_user = User.find_by(params[:name])
    data_list.each do |data|
      UserData.create(
        user_id: current_user.id,
        content: data[:content],
        created_at: DateTime.strptime(data[:created_at], "%Y-%m-%d %H:%M:%S"),
        updated_at: DateTime.strptime(data[:updated_at], "%Y-%m-%d %H:%M:%S")
      )
    end
    @detail_data = { message: "成功上传 #{data_list.count} 条数据" }
    @status = :ok
  end

  def pull_data
    time_stamp_list = (params[:list] ||= [])
    current_user = User.find_by(params[:name])
    time_stamp_list.each do |time_stamp|
      user_data = UserData.find_by(user_id: current_user.id, created_at: time_stamp[:created_at], updated_at: time_stamp[:updated_at])
      data_list << { create_at: time_stamp[:created_at], updated_at: time_stamp, content: user_data.content } unless user_data.blank?
    end
    @status = :ok
    @detail_data = { list: data_list ||= [] }
  end

  def sync_data
    check_data(sync_data = true)
  end

  private

  def get_push_list
    # 这里new和update是指客户端相对服务端的状态，即服务端缺少和陈旧的记录
    new_list = update_list = []
    @check_list.each do |time_stamp|
      index = @server_list.index{ |ts| ts[:created_at].strftime("%Y-%m-%d %H:%M:%S") == time_stamp[:created_at] }
      if index.nil?
        new_list << { created_at: time_stamp[:created_at], updated_at: time_stamp[:created_at] }
      elsif @server_list[index][:updated_at] < DateTime.strptime(time_stamp[:updated_at], "%Y-%m-%d %H:%M:%S")
        update_list << { created_at: time_stamp[:created_at], updated_at: time_stamp[:created_at] }
      end
    end

    new_list + update_list
  end

  def get_pull_list(with_content = false)
    # 这里new和update是指服务端相对客户端的状态，即客户端缺少和陈旧的记录
    new_list = update_list = []
    @server_list.each do |time_stamp|
      server_created_at = time_stamp[:created_at].strftime("%Y-%m-%d %H:%M:%S")
      server_updated_at = time_stamp[:updated_at].strftime("%Y-%m-%d %H:%M:%S")
      index = @check_list.index{ |ts| ts[:created_at] == server_created_at}
      if index.nil?
        new_list << { created_at: server_created_at, updated_at: server_updated_at }
      elsif time_stamp[:updated_at] > DateTime.strptime(@check_list[index][:updated_at], "%Y-%m-%d %H:%M:%S")
        update_list << { created_at: server_created_at, updated_at: server_updated_at }
      end
    end

    new_list + update_list
  end

end
