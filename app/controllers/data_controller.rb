class DataController < ApplicationController
  before_action :check_params
  before_action :auth_token
  after_action  :do_response
  
  def check_data
    @check_list = (params[:check_list] ||= [])
    current_user = User.find_by(name: params[:name])
    @server_list = current_user.user_data.collect{ |user_data| { created_at: user_data.created_at, updated_at: user_data.updated_at } }

    @detail_data = { 
      push_list: get_push_list,
      pull_list: get_pull_list(false)
    }
    @status = :ok
  end

  def push_data
    data_list = (params[:list] ||= [])
    current_user = User.find_by(name: params[:name])
    data_list.each do |data|
      UserData.create(
        user_id: current_user.id,
        content: data[:content],
        created_at: DateTime.strptime(data[:created_at], "%Y-%m-%d %H:%M:%S"),
        updated_at: DateTime.strptime(data[:updated_at], "%Y-%m-%d %H:%M:%S")
      )
    end
    @detail_data = { msg: "成功上传 #{data_list.count} 条数据", count: data_list.count }
    @status = :ok
  end

  def pull_data
    time_stamp_list = (params[:list] ||= [])
    data_list = []
    current_user = User.find_by(name: params[:name])
    time_stamp_list.each do |time_stamp|
      user_data = UserData.find_by(user_id: current_user.id, created_at: time_stamp[:created_at], updated_at: time_stamp[:updated_at])
      data_list << { create_at: time_stamp[:created_at], updated_at: time_stamp[:updated_at], content: user_data.content } unless user_data.blank?
    end
    @status = :ok
    @detail_data = { list: data_list }
  end

  def sync_data
    @check_list = (params[:check_list] ||= [])
    current_user = User.find_by(name: params[:name])
    @server_list = current_user.user_data.collect{ |user_data| { created_at: user_data.created_at, updated_at: user_data.updated_at, content: user_data.content } }

    @detail_data = { 
      push_list: get_push_list,
      pull_list: get_pull_list(true)
    }
    @status = :ok
  end

  private

  def get_push_list
    # 这里new和update是指客户端相对服务端的状态，即服务端缺少和陈旧的记录
    new_list = []
    update_list = []
    @check_list.each do |time_stamp|
      index = @server_list.index{ |ts| ts[:created_at].strftime("%Y-%m-%d %H:%M:%S") == time_stamp[:created_at] }
      if index.nil?
        new_list << { created_at: time_stamp[:created_at], updated_at: time_stamp[:updated_at] }
      elsif @server_list[index][:updated_at] < DateTime.strptime(time_stamp[:updated_at], "%Y-%m-%d %H:%M:%S")
        update_list << { created_at: time_stamp[:created_at], updated_at: time_stamp[:updated_at] }
      end
    end

    new_list + update_list
  end

  def get_pull_list(with_content)
    # 这里new和update是指服务端相对客户端的状态，即客户端缺少和陈旧的记录
    new_list = []
    update_list = []
    @server_list.each do |server_data|
      server_created_at = server_data[:created_at].strftime("%Y-%m-%d %H:%M:%S")
      server_updated_at = server_data[:updated_at].strftime("%Y-%m-%d %H:%M:%S")
      index = @check_list.index{ |ts| ts[:created_at] == server_created_at}

      if index.nil?
        data = { created_at: server_created_at, updated_at: server_updated_at }
        data.merge!(content: server_data[:content]) if with_content
        new_list << data
      elsif server_data[:updated_at] > DateTime.strptime(@check_list[index][:updated_at], "%Y-%m-%d %H:%M:%S")
        data = { created_at: server_created_at, updated_at: server_updated_at }
        data.merge!(content: server_data[:content]) if with_content
        update_list << data
      end
    end

    new_list + update_list
  end

end
