module RedmineWorkWechat
  module Patches
    module Models
      module JournalPatch
        include RedmineWorkWechat::Helper

        def self.prepended(base)
          base.class_eval do
            after_create_commit :send_notification
          end
        end

        def send_notification
          return unless RedmineWorkWechat.available?

          work_wechat_users = []
          journal = self
          users = journal.notified_users | journal.notified_watchers | journal.notified_mentions | journal.journalized.notified_mentions
          users.select! do |user|
            journal.notes? || journal.visible_details(user).any?
          end
          users.each do |user|
            work_wechat_users << user.mail
          end

          if issue.author.pref.no_self_notified
            addresses = issue.author.mails
            work_wechat_users -= addresses if work_wechat_users.is_a?(Array)
          end

          return if work_wechat_users.empty?

          content = "`#{l('text_updated_issue')}`\n"
          content += render_markdown(journal.user, journal.journalized, journal)

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

Journal.prepend RedmineWorkWechat::Patches::Models::JournalPatch
