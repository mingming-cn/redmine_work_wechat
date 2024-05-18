require_relative '../../work_wechat'

module RedmineWorkWechat
  module Patches
    module Models
      module IssuePatch
        include RedmineWorkWechat::Helper

        def self.prepended(base)
          base.class_eval do
            after_create_commit :send_notification
          end
        end

        def send_notification
          work_wechat_users = Array.[]
          issue = self
          users = issue.notified_users | issue.notified_watchers | issue.notified_mentions
          users.each do |user|
            work_wechat_users << user.mail
          end

          content = "`#{l('created_new_issue')}`\n\n"
          content += render_markdown(issue.author, issue)
          RedmineWorkWechat::WorkWechat.deliver_markdown_msg(work_wechat_users, content)
        end
      end
    end
  end
end

Issue.prepend RedmineWorkWechat::Patches::Models::IssuePatch
