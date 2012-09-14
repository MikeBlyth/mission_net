require "#{Rails.root}/app/helpers/application_helper.rb"
include ApplicationHelper

desc "Remove old records from AppLog, Message and SentMessage tables"
task :clean_old => :environment do
  puts 'cleaning log and old DB records ...'
  clean_old_file_entries(AppLog, :max_to_keep => SiteSetting.log_max_records, 
     :retention_days => SiteSetting.log_retention_period)
  clean_old_file_entries(SentMessage, :max_to_keep => SiteSetting.log_max_records, 
     :retention_days => SiteSetting.log_retention_period)
  clean_old_file_entries(Message, :max_to_keep => SiteSetting.messages_max_records, 
     :retention_days => SiteSetting.messages_retention_period)
end

