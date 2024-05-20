module RedmineWorkWechat
  module Helper
    include IssuesHelper
    include CustomFieldsHelper

    def render_markdown(author, issue, journal=nil)
      content = []
      content << ''
      content << "<font color=\"info\">#{issue.tracker.name} \[\##{issue.id}\] #{issue.subject}</font>"

      # attach journal content
      if journal
        content << l(:text_updated, author: author)

        details_to_strings(journal.visible_details, true).each do |string|
          content << "<font color=\"warning\">#{string}</font>"
        end

        if journal.notes?
          content << if journal.private_notes?
                       "<font color=\"warning\">#{l(:text_add_private_notes)}</font>"
                     else
                       "<font color=\"warning\">#{l(:text_add_notes)}</font>"
                     end
          content << "<font color=\"warning\">#{journal.notes}</font>"
        end
      end

      # attributes and description
      content << ''
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
      issue_link += "#change-#{journal.id}" if journal

      arr_to_quote(content) + "\n\n[#{l('text_view_details')}](#{issue_link})"
    end

    def arr_to_quote(arr)
      arr.map { |s| "> #{s.gsub("\n", "\n> ")}" }.join("\n")
    end

  end
end
