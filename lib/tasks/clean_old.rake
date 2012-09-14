require "#{Rails.root}/app/helpers/heroku_helper.rb"

desc "Remove old records from AppLog, Message and SentMessage tables"
task :clean_old => :environment do
  puts 'cleaning log and old DB records ...'
  clean_old_file_entries(AppLog, options={:max_to_keep => SiteSetting.log_max_records, 
     :before_date => Date.today - SiteSetting.log_retention_period.days})
  clean_old_file_entries(SentMessage, options={:max_to_keep => SiteSetting.log_max_records, 
     :before_date => Date.today - SiteSetting.log_retention_period.days})
  clean_old_file_entries(Message, options={:max_to_keep => SiteSetting.message_max_records, 
     :before_date => Date.today - SiteSetting.message_retention_period.days})
end

#task :send_reminders => :environment do
#    User.send_reminders
#end
