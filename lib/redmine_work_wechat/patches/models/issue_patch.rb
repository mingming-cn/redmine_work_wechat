require_relative '../../work_wechat'

module RedmineWorkWechat
  module Patches
    module Models
      module IssuePatch

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

          subject = "#{issue.tracker.name} [##{issue.id}] (#{issue.status.name}) #{issue.subject}"
          link = "#{Setting.protocol}://#{Setting.host_name}/issues/#{@issue.id}"

          RedmineWorkWechat::WorkWechat.deliver_card_msg(work_wechat_users, l("created_new_issue"), subject, link)
        end
      end
    end
  end
end

Issue.prepend RedmineWorkWechat::Patches::Models::IssuePatch
