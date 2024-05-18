require "net/http"
require "json"

module RedmineWorkWechat
  module WorkWechat
    @get_access_token_url = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=%s&corpsecret=%s'
    @send_msg_url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s'
    @cache_key = '_work_wechat_access_token'
    @cache_key_expired_at = '_work_wechat_access_token_expired_at'

    def self.get_access_token
      access_token = Rails.cache.read(@cache_key)
      expired_at = Rails.cache.read(@cache_key_expired_at)
      return access_token if !access_token.blank? && !expired_at.blank? && (Time.now < Time.at(expired_at.to_i))

      corpid = RedmineWorkWechat::settings_hash['corpid']
      secret = RedmineWorkWechat::settings_hash['secret']
      uri = URI(@get_access_token_url % [corpid, secret])

      resp = get_http_client(uri).request(Net::HTTP::Get.new(uri.request_uri))
      json = JSON.parse(resp.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      raise "get access token failed: #{errcode} - #{errmsg}" if errcode != 0

      access_token = json['access_token']
      expires_in = json['expires_in']
      expired_at = Time.now + expires_in - 30

      Rails.cache.write(@cache_key, access_token)
      Rails.cache.write(@cache_key_expired_at, expired_at)
      access_token
    end

    def self.deliver_card_msg(users, title, msg, url = '', btntxt = '查看详情')
      puts "send card message to: #{users.join('|')}"

      uri = URI(@send_msg_url % [get_access_token])
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
      resp = get_http_client(uri).request(req)

      json = JSON.parse(resp.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      raise "send card message failed: #{errcode} - #{errmsg}" if errcode != 0
    end

    def self.deliver_markdown_msg(users, msg)
      puts "send markdown message to: #{users.join('|')}"

      uri = URI(@send_msg_url % [get_access_token])
      req = Net::HTTP::Post.new(uri.request_uri)
      req_data = {
        :touser => users.join('|'),
        :msgtype => 'markdown',
        :agentid => RedmineWorkWechat::settings_hash['agentid'],
        :markdown => {
          :content => msg,
        },
      }
      req.body = JSON.dump(req_data)
      resp = get_http_client(uri).request(req)

      json = JSON.parse(resp.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      raise "send markdown message failed: #{errcode} - #{errmsg}" if errcode != 0
    end

    def self.get_http_client(uri)
      proxy = RedmineWorkWechat::settings_hash['proxy'].split(':')
      if proxy.length == 2
        http = Net::HTTP.new(uri.host, uri.port, proxy.first, proxy.last)
        http.use_ssl = true
        return http
      end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http
    end
  end
end
