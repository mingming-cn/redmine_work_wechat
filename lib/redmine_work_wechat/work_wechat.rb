require "net/http"
require "json"

module RedmineWorkWechat
  module WorkWechat
    @get_access_token_url = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=%s&corpsecret=%s'
    @send_msg_url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s'
    @cache_key = '_work_wechat_access_token'

    def self.get_access_token
      access_token = Rails.cache.read(@cache_key)
      unless access_token.blank?
        return access_token
      end

      corpid = RedmineWorkWechat::settings_hash['corpid']
      secret = RedmineWorkWechat::settings_hash['secret']

      uri = URI(@get_access_token_url % [corpid, secret])
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Get.new(uri.request_uri)
      res = http.request(req)

      json = JSON.parse(res.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      if errcode != 0
        raise "get access token failed: #{errcode} - #{errmsg}"
      end

      access_token = json['access_token']
      expires_in = json['expires_in']
      expired_at = Time.now + expires_in - 30

      Rails.cache.write(@cache_key, access_token, expires_at: expired_at)

      access_token
    end

    def self.deliver_card_msg(users, title, msg, url = '', btntxt = '查看详情')
      proxy = RedmineWorkWechat::settings_hash['proxy'].split(':')
      uri = URI(@send_msg_url % [get_access_token])
      http = Net::HTTP.new(uri.host, uri.port, proxy.at(0),  proxy.at(1))
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.request_uri)
      req_data = {
        :touser => users.join('|'),
        :msgtype => 'textcard',
        :agentid => RedmineWorkWechat::settings_hash['agentid'],
        :textcard => {
          :title => title,
          :description => msg,
          :url => url,
          :btntxt => btntxt
        },
      }
      req.body = JSON.dump(req_data)
      res = http.request(req)

      json = JSON.parse(res.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      if errcode != 0
        raise "send card message failed: #{errcode} - #{errmsg}"
      end
    end

    def self.deliver_markdown_msg(users, msg)
      proxy = RedmineWorkWechat::settings_hash['proxy'].split(':')
      uri = URI(@send_msg_url % [get_access_token])
      http = Net::HTTP.new(uri.host, uri.port, proxy.at(0),  proxy.at(1))
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri.request_uri)
      req_data = {
        :touser => users.join('|'),
        :msgtype => 'markdown',
        :agentid => RedmineWorkWechat::settings_hash['agentid'],
        :markdown => {
          :content => content,
        },
      }
      req.body = JSON.dump(req_data)
      res = http.request(req)

      json = JSON.parse(res.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      if errcode != 0
        raise "send markdown message failed: #{errcode} - #{errmsg}"
      end
    end
  end
end
