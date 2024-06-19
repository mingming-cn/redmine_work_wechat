desc <<-END_DESC
Send reminders about issues due in the next days.

Example:
  rake redmine:send_reminders days=7 users="1,23, 56" RAILS_ENV="production"
END_DESC

namespace :redmine do
  task :send_work_wechat => :environment do
    require_relative '../../../../config/environment'
    include RedmineWorkWechat::Reminder

    options = {}
    options[:days] = ENV['days'].presence&.to_i
    options[:project] = ENV['project'].presence
    options[:tracker] = ENV['tracker'].presence&.to_i
    options[:users] = ENV['users'].presence.to_s.split(',').each(&:strip!)
    options[:version] = ENV['version'].presence

    unless RedmineWorkWechat::available?
      puts "WorkWechat is not configured, skipped."
      return
    end

    reminders(options)
  end
end
