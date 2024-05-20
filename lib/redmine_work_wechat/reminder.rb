module RedmineWorkWechat
  module Reminder
    include Redmine::I18n
    include ActionView::Helpers::DateHelper
    include IssuesHelper
    include Helper

    I18n.locale = Setting.default_language

    # Sends reminders to issue assignees
    # Available options:
    # * :days     => how many days in the future to remind about (defaults to 7)
    # * :tracker  => id of tracker for filtering issues (defaults to all trackers)
    # * :project  => id or identifier of project to process (defaults to all projects)
    # * :users    => array of user/group ids who should be reminded
    # * :version  => name of target version for filtering issues (defaults to none)
    def reminders(options = {})
      days = options[:days] || 7
      project = options[:project] ? Project.find(options[:project]) : nil
      tracker = options[:tracker] ? Tracker.find(options[:tracker]) : nil
      target_version_id = options[:version] ? Version.named(options[:version]).pluck(:id) : nil
      if options[:version] && target_version_id.blank?
        raise ActiveRecord::RecordNotFound.new("Couldn't find Version named #{options[:version]}")
      end

      user_ids = options[:users]

      scope =
        Issue.open.where(
          "#{Issue.table_name}.assigned_to_id IS NOT NULL" \
            " AND #{Project.table_name}.status = #{Project::STATUS_ACTIVE}" \
            " AND #{Issue.table_name}.due_date <= ?", days.day.from_now.to_date
        )
      scope = scope.where(:assigned_to_id => user_ids) if user_ids.present?
      scope = scope.where(:project_id => project.id) if project
      scope = scope.where(:fixed_version_id => target_version_id) if target_version_id.present?
      scope = scope.where(:tracker_id => tracker.id) if tracker
      issues_by_assignee = scope.includes(:status, :assigned_to, :project, :tracker).
        group_by(&:assigned_to)
      issues_by_assignee.keys.each do |assignee| # rubocop:disable Style/HashEachMethods
        if assignee.is_a?(Group)
          assignee.users.each do |user|
            issues_by_assignee[user] ||= []
            issues_by_assignee[user] += issues_by_assignee[assignee]
          end
        end
      end

      issues_by_assignee.each do |assignee, issues|
        if assignee.is_a?(User) && assignee.active? && issues.present?
          visible_issues = issues.select { |i| i.visible?(assignee) }
          visible_issues.sort! { |a, b| (a.due_date <=> b.due_date).nonzero? || (a.id <=> b.id) }
          if visible_issues.present?
            reminder(assignee, visible_issues, days)
          end
        end
      end
    end

    def reminder(user, issues, days)
      content = []

      content << "<font color=\"warning\">%s</font>" % [l(:mail_body_reminder, :count => issues.size, :days => days)]

      projects = {}
      issues.each do |issue|
        projects[issue.project] ||= []
        projects[issue.project] << issue
      end

      projects.each do |project, p_issues|
        content << ''
        content << "**#{project}:**"
        p_issues.each do |issue|
          issue_link = "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
          content << "   [#{issue.tracker} ##{issue.id}](#{issue_link}): #{issue.subject} (#{due_date_distance_in_words(issue.due_date)})"
        end
      end

      open_issues_url = "#{Setting.protocol}://#{Setting.host_name}/issues?assigned_to_id=me&set_filter=1&sort=due_date%3Aasc"
      content =  "`#{l(:text_issues_remind)}`\n" +
                 content.map { |s| "> #{s}" }.join("\n") +
                 "\n[#{l(:label_issue_view_all)}](#{open_issues_url})"

      WorkWechat.deliver_markdown_msg([user.mail], content)
    end
  end

end
