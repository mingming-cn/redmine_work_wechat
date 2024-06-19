class WorkWechatController < ApplicationController
  accept_api_auth :js_sdk_config

  def js_sdk_config
    puts params['page_url']
    unless RedmineWorkWechat.available?
      render json: { err: 'please configure WorkWechat' }
      return
    end

    if params['page_url'].nil?
      render json: { err: 'page_url is required' }
      return
    end

    begin
      config = {
        timestamp: Time.now.to_i,
        noncestr: SecureRandom.hex,
        jsapi_ticket: RedmineWorkWechat::WorkWechat.get_jsapi_ticket,
        url: params['page_url']
      }

      sign_str = "jsapi_ticket=#{config[:jsapi_ticket]}&noncestr=#{config[:noncestr]}&timestamp=#{config[:timestamp]}&url=#{config[:url]}"
      config[:signature] = Digest::SHA1.hexdigest(sign_str)
      render json: config
    rescue StandardError => e
      render json: { err: "get js_sdk_config error: #{e.message}" }
    end
  end
end
