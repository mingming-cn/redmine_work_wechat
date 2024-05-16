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
          puts "11111111111111111111"
        end
      end
    end
  end
end

Issue.prepend RedmineWorkWechat::Patches::Models::IssuePatch
