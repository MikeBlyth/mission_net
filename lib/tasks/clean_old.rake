require "#{Rails.root}/app/helpers/heroku_helper.rb"

desc "This task is called by the Heroku scheduler add-on"
task :clean_old => :environment do
  puts 'cleaning log and old DB records ...'
  
  # Clean log file
  log_max = SiteSetting.max_log_records_to_keep || 4000
  if log_max > 0 && AppLog.count > log_max
    date_limit = AppLog.order('created_at DESC').offset(log_max).limit(1)[0].created_at
    AppLog.where('created_at < ?', date_limit).delete_all
  end
end

#task :send_reminders => :environment do
#    User.send_reminders
#end
