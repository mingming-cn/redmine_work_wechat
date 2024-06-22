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

          issue = self
          users = issue.notified_users | issue.notified_watchers | issue.notified_mentions
          work_wechat_users = extract_user_ids(users)

          if issue.author.pref.no_self_notified
            work_wechat_users -= extract_user_ids(issue.author) if work_wechat_users.is_a?(Array)
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
