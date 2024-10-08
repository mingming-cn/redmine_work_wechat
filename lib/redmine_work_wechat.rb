module RedmineWorkWechat
  class << self
    def settings_hash
      Setting['plugin_redmine_work_wechat']
    end

    def enabled?
      settings_hash['enabled']
    end

    def available?
      enabled? && corpid.present? && agentid.present? && secret.present?
    end

    def corpid
      settings_hash['corpid']
    end

    def agentid
      settings_hash['agentid']
    end

    def secret
      settings_hash['secret']
    end

    def proxy
      settings_hash['proxy']
    end

    def user_relation
      settings_hash['user_relation']
    end

    def notification_include_details?
      settings_hash['notification_include_details']
    end

    def notification_include_details_size
      size = settings_hash['notification_include_details_size']
      return 200 if size.empty?

      Integer(size)
    end

    def open_in_default_browser?
      settings_hash['open_in_default_browser']
    end
  end
end
