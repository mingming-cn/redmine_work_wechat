module RedmineWorkWechat
  module Hooks
    class UserProfile < Redmine::Hook::ViewListener

      def view_users_form(context = {})
        work_wechat_user_id_options(context)
      end

      def work_wechat_user_id_options(context)
        user = context[:user]
        s = ''
        if user && User.current.admin?
          s << "<p>"
          s << label_tag("user_work_wechat_user_id", l(:label_work_wechat_user_id))
          s << text_field_tag('user[work_wechat_user_id]', user.work_wechat_user_id, size: 100)
          s << "</p>"
        end

        s.html_safe
      end
    end
  end
end

