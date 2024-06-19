require 'net/http'
require 'json'

module RedmineWorkWechat
  module WorkWechat
    @get_access_token_url = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=%s&corpsecret=%s'
    @send_msg_url = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=%s'
    @jsapi_ticket_url = 'https://qyapi.weixin.qq.com/cgi-bin/get_jsapi_ticket?access_token=%s'
    @ckey_jsapi_ticket = '_work_wechat_jsapi_ticket'
    @ckey_jsapi_ticket_expired_at = '_work_wechat_jsapi_ticket_expired_at'
    @ckey_access_token = '_work_wechat_access_token'
    @ckey_access_token_expired_at = '_work_wechat_access_token_expired_at'

    def self.get_http_client(uri)
      http = Net::HTTP.new(uri.host, uri.port)

      if RedmineWorkWechat.settings_hash['proxy'].present?
        proxy = RedmineWorkWechat.settings_hash['proxy'].split(':')
        if proxy.length == 1
          http = Net::HTTP.new(uri.host, uri.port, proxy.first, 80)
        elsif proxy.length == 2
          http = Net::HTTP.new(uri.host, uri.port, proxy.first, proxy.last)
        end
      end

      http.use_ssl = true
      http.open_timeout = 2
      http.read_timeout = 2
      http.write_timeout = 2
      http
    end

    def self.get_jsapi_ticket
      ticket = Rails.cache.read(@ckey_jsapi_ticket)
      expired_at = Rails.cache.read(@ckey_jsapi_ticket_expired_at)
      puts "local ticket: #{ticket}"
      return ticket if !ticket.blank? && !expired_at.blank? && (Time.now < Time.at(expired_at.to_i))

      uri = URI(format(@jsapi_ticket_url, get_access_token))
      resp = get_http_client(uri).request(Net::HTTP::Get.new(uri.request_uri))
      json = JSON.parse(resp.body)
      errcode = json['errcode']
      errmsg = json['errmsg']

      if errcode != 0
        puts "redmine_work_wechat: get access token failed: #{errcode} - #{errmsg}"
        return ''
      end

      ticket = json['ticket']
      expires_in = json['expires_in']
      expired_at = Time.now + expires_in - 30

      puts "remote ticket: #{ticket}"
      Rails.cache.write(@ckey_jsapi_ticket, ticket)
      Rails.cache.write(@ckey_jsapi_ticket_expired_at, expired_at)
      ticket
    end

    def self.get_access_token
      access_token = Rails.cache.read(@ckey_access_token)
      expired_at = Rails.cache.read(@ckey_access_token_expired_at)
      return access_token if !access_token.blank? && !expired_at.blank? && (Time.now < Time.at(expired_at.to_i))

      corpid = RedmineWorkWechat.settings_hash['corpid']
      secret = RedmineWorkWechat.settings_hash['secret']
      uri = URI(format(@get_access_token_url, corpid, secret))
      resp = get_http_client(uri).request(Net::HTTP::Get.new(uri.request_uri))
      json = JSON.parse(resp.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      raise "get access token failed: #{errcode} - #{errmsg}" if errcode != 0

      access_token = json['access_token']
      expires_in = json['expires_in']
      expired_at = Time.now + expires_in - 30

      Rails.cache.write(@ckey_access_token, access_token)
      Rails.cache.write(@ckey_access_token_expired_at, expired_at)
      access_token
    end

    def self.deliver_card_msg(users, title, msg, url = '', btntxt = '查看详情')
      puts "send card message to: #{users.join('|')}"

      uri = URI(format(@send_msg_url, get_access_token))
      req = Net::HTTP::Post.new(uri.request_uri)
      req_data = {
        touser: users.join('|'),
        msgtype: 'textcard',
        agentid: RedmineWorkWechat.settings_hash['agentid'],
        textcard: {
          title: title,
          description: msg,
          url: url,
          btntxt: btntxt
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

      uri = URI(format(@send_msg_url, get_access_token))
      req = Net::HTTP::Post.new(uri.request_uri)
      req_data = {
        touser: users.join('|'),
        msgtype: 'markdown',
        agentid: RedmineWorkWechat.settings_hash['agentid'],
        markdown: {
          content: msg,
        }
      }
      req.body = JSON.dump(req_data)
      resp = get_http_client(uri).request(req)

      json = JSON.parse(resp.body)
      errcode = json['errcode']
      errmsg = json['errmsg']
      raise "send markdown message failed: #{errcode} - #{errmsg}" if errcode != 0
    end

  end
end
