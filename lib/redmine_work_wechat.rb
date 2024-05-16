require_relative 'redmine_work_wechat/patches/models/issue_patch'

module RedmineWorkWechat
  class << self
    def settings_hash
      Setting["plugin_redmine_work_wechat"]
    end

    def enabled?
      settings_hash["enabled"]
    end

    def corpid
      settings_hash["corpid"]
    end

    def agentid
      settings_hash["agentid"]
    end

    def secret
      settings_hash["secret"]
    end
  end
end
