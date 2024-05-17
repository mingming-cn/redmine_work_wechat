module RedmineWorkWechat
  module Helper
    include IssuesHelper
    include CustomFieldsHelper

    def render_markdown(author, issue, journal=nil)
      content = ''

      content += "> <font color=\"info\">#{issue.tracker.name} \[\##{issue.id}\] #{issue.subject}</font>\n\n"

      if journal
        content += "> " + l(:text_issue_updated, :id => "##{issue.id}", :author => author) + "\n"

        if journal.private_notes?
          content = "> (#{l(:field_private_notes)}): " + content + "\n\n"
        end

        details_to_strings(journal.visible_details, true).each do |string|
          content += "> <font color=\"warning\">" + string + "</font>\n\n"
        end

        if journal.notes?
          content += journal.notes + "\n\n"
        end
      end

      content += render_issue_attributes(issue, author) + "\n\n"

      content += "> #{l(:field_description)}: \n" + issue.description + "\n\n"

      if issue.attachments.any?
        content += "> " + l(:label_attachment_plural).ljust(37, '-') + "\n\n"
        issue.attachments.each do |attachment|
          content += "#{attachment.filename} (#{attachment.filesize})"  + "\n\n"
        end
      end

      issue_link = "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
      if journal
        issue_link += "#change-#{journal.id}"
      end

      content += "\n\n[#{l('view_details')}](#{issue_link})"
      content
    end

    def render_issue_attributes(issue, user)
      items = email_issue_attributes(issue, user, false)
      items.map{|s| "> #{s}"}.join("\n")
    end

  end
end
