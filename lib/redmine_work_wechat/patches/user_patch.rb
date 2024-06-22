module RedmineWorkWechat
  module Patches
    module UserPatch
      def self.included(base)
        base.class_eval do
          unloadable

          safe_attributes 'work_wechat_user_id'
        end
      end
    end
  end
end

unless User.included_modules.include?(RedmineWorkWechat::Patches::UserPatch)
  User.include RedmineWorkWechat::Patches::UserPatch
end
