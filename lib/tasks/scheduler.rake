require "#{Rails.root}/app/helpers/heroku_helper.rb"

desc "This task is called by the Heroku scheduler add-on"
task :kill_workers => :environment do
  puts 'Checking job queue ...'
  if ::Delayed::Job.all.empty?
    puts 'removing workers'
    heroku = Heroku::API.new(:api_key => 'd758366a60299d3bb593d2aae9ae3b7455eacd14')
    puts heroku.post_ps_scale('joslink', 'worker', "0").body
  end
end

#task :send_reminders => :environment do
#    User.send_reminders
#end
