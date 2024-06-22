class WorkWechatController < ApplicationController
  skip_before_action :check_if_login_required

  def js_sdk_config
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
