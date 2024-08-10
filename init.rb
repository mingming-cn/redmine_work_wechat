require 'redmine'
require_relative 'lib/redmine_work_wechat'

Redmine::Plugin.register :redmine_work_wechat do
  name 'Redmine Work Wechat plugin'
  author 'mingming.wang'
  description 'This is a plugin of Work Wechat for Redmine'
  version '0.0.3'
  url 'https://github.com/mingming-cn/redmine_work_wechat'
  author_url 'https://mingming.wang'

  settings default: { 'enabled' => false, 'corpid' => '', 'agentId' => '', 'secret' => '', 'user_relation' => 'email',
                      'open_in_default_browser' => false, 'notification_include_details_size' => 200,
                      'notification_include_details' => true },
           partial: 'settings/work_wechat_settings'
end
