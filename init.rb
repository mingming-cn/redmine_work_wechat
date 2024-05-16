require 'redmine'
require_relative 'lib/redmine_work_wechat'


Redmine::Plugin.register :redmine_work_wechat do
  name 'Redmine Work Wechat plugin'
  author 'mingming.wang'
  description 'This is a plugin of Work Wechat for Redmine'
  version '0.0.1'
  url 'https://github.com/mingming-cn/redmine_work_wechat'
  author_url 'https://mingming.wang'
  settings :default => { 'enabled' => 'true', 'corpid' => '', 'agentId' => '',  'secret' => '' },
           :partial => 'settings/work_wechat_settings'
end
