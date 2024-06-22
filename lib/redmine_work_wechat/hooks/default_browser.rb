module RedmineWorkWechat
  module Hooks
    class DefaultBrowser < Redmine::Hook::ViewListener
      require 'digest/sha1'

      render_on :view_layouts_base_html_head, partial: 'default_browser/default_browser_head'

      def self.js_sdk_config(request)
        return {} unless RedmineWorkWechat.available?

        begin
          config = {
            timestamp: Time.now.to_i,
            noncestr: SecureRandom.hex,
            jsapi_ticket: RedmineWorkWechat::WorkWechat.get_jsapi_ticket,
            url: request.base_url + request.original_fullpath
          }

          sign_str = "jsapi_ticket=#{config[:jsapi_ticket]}&noncestr=#{config[:noncestr]}&timestamp=#{config[:timestamp]}&url=#{config[:url]}"
          config[:signature] = Digest::SHA1.hexdigest(sign_str)
          config
        rescue StandardError
          {}
        end
      end

    end
  end
end

