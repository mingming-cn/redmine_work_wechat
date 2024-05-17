module RedmineWorkWechat
  module Patches
    module Models
      module JournalPatch
        def self.prepended(base)
          base.class_eval do
            after_create_commit :send_notification
          end
        end

        def send_notification
          work_wechat_users = Array.[]
          journal = self
          users = journal.notified_users | journal.notified_watchers | journal.notified_mentions | journal.journalized.notified_mentions
          users.select! do |user|
            journal.notes? || journal.visible_details(user).any?
          end
          users.each do |user|
            work_wechat_users << user.mail
          end

          issue = journal.journalized
          link = url_for(:controller => 'issues', :action => 'show', :id => issue, :anchor => "change-#{journal.id}")

          content = "# #{issue.tracker.name} [##{issue.id}] #{issue.subject}\n"
          content += "[查看详情](#{link})"

          RedmineWorkWechat::WorkWechat.deliver_markdown_msg(work_wechat_users, content)
        end
      end
    end
  end
end

Issue.prepend RedmineWorkWechat::Patches::Models::IssuePatch
