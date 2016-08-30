class Response

  def self.params_error
    { code: CONFIG[:params_error], ret: {} }
  end

  def self.token_error
    { code: CONFIG[:token_error], ret: {} }
  end

  def self.build_response(action, status, detail_data)
    response = { 
      code: CONFIG[:valid_response],
      ret: {
        code: CONFIG[action][status]["code"],
        msg: CONFIG[action][status]["msg"]
      }
    }

    detail_data.each{ |key, value| response[:ret][key] = value }
    response
  end

end