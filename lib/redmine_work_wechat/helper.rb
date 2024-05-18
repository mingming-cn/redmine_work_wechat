module RedmineWorkWechat
  module Helper
    include IssuesHelper
    include CustomFieldsHelper

    def render_markdown(author, issue, journal=nil)
      content = Array.[]
      content << "\n"
      content << "<font color=\"info\">#{issue.tracker.name} \[\##{issue.id}\] #{issue.subject}</font>"

      # attach journal content
      if journal
        content << l(:text_issue_updated, :id => "##{issue.id}", :author => author)

        if journal.private_notes?
          content << "#{l(:field_private_notes)} "
        end

        details_to_strings(journal.visible_details, true).each do |string|
          content << "<font color=\"warning\">#{string}</font>"
        end

        if journal.notes?
          content << journal.notes
        end
      end

      # attributes and description
      content << "\n"
      content += email_issue_attributes(issue, author, false)
      content << "#{l(:field_description)}: "
      content << issue.description

      # attachments list
      if issue.attachments.any?
        content << l(:label_attachment_plural).ljust(37, '-')
        issue.attachments.each do |attachment|
          content << "#{attachment.filename} (#{attachment.filesize})"
        end
      end

      # more link
      issue_link = "#{Setting.protocol}://#{Setting.host_name}/issues/#{issue.id}"
      if journal
        issue_link += "#change-#{journal.id}"
      end
      content << "\n"

      content.map{|s| "> #{s}"}.join("\n") +  "\n\n [#{l('view_details')}](#{issue_link})"
    end

  end
end
