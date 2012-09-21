require "#{Rails.root}/app/helpers/application_helper.rb"
include ApplicationHelper

desc "Reset the max index on all the relevant tables (used for some DB errors)"
task :resync_max_ids => :environment do
  puts 'Resetting the max index on all the relevant tables'
  resync_pg_database_max_ids
end


