require "#{Rails.root}/app/helpers/heroku_helper.rb"

desc "Update members' in-country status based on arr & dep dates. Run by Heroku scheduler"
task :update_in_country => :environment do
  puts 'Updating in-country statuses ...'
  Member.auto_update_all_in_country_statuses 
end

