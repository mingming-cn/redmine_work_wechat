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
          return unless RedmineWorkWechat.available?

          work_wechat_users = []
          issue = self
          users = issue.notified_users | issue.notified_watchers | issue.notified_mentions
          users.each do |user|
            work_wechat_users << user.mail
          end

          if issue.author.pref.no_self_notified
            addresses = issue.author.mails
            work_wechat_users -= addresses if work_wechat_users.is_a?(Array)
          end

          return if work_wechat_users.empty?

          content = "`#{l('text_created_new_issue')}`\n"
          content += render_markdown(issue.author, issue)

          begin
            RedmineWorkWechat::WorkWechat.deliver_markdown_msg(work_wechat_users, content)
          rescue StandardError => e
            Rails.logger.error "send work wechat msg failed: #{e.message}"
          end
        end
      end
    end
  end
end

Issue.prepend RedmineWorkWechat::Patches::Models::IssuePatch
