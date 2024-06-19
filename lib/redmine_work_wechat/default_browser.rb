module RedmineWorkWechat
  class DefaultBrowser < Redmine::Hook::ViewListener
    require 'digest/sha1'

    render_on :view_layouts_base_html_head, partial: "default_browser/default_browser_head"
    render_on :view_layouts_base_body_bottom, partial: "default_browser/default_browser_foot"

    def self.js_sdk_config(request)
      unless RedmineWorkWechat.available?
        return {}
      end

      begin
        config = {
          :timestamp => Time.now.to_i,
          :noncestr => SecureRandom.hex,
          :jsapi_ticket => RedmineWorkWechat::WorkWechat.get_jsapi_ticket,
          :url => request.base_url + request.original_fullpath
        }

        sign_str = format("jsapi_ticket=%s&noncestr=%s&timestamp=%d&url=%s",
                          config[:jsapi_ticket], config[:noncestr], config[:timestamp], config[:url])
        config[:signature] = Digest::SHA1.hexdigest(sign_str)
        config
      rescue
        {}
      end
    end

  end
end

