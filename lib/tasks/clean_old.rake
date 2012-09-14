require "#{Rails.root}/app/helpers/heroku_helper.rb"

desc "This task is called by the Heroku scheduler add-on"
task :clean_old => :environment do
  puts 'cleaning log and old DB records ...'
  
end

#task :send_reminders => :environment do
#    User.send_reminders
#end
