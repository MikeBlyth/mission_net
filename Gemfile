source 'https://rubygems.org'

gem 'rails', '3.2.5'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'haml'
gem 'twilio-ruby'
gem 'httparty'
gem 'active_scaffold', :git => 'git://github.com/activescaffold/active_scaffold.git'
gem 'settingslogic'
gem 'configurable_engine'
gem 'omniauth', '~> 1.0.0'
gem 'omniauth-facebook'
#gem 'omniauth-youtube'
gem 'omniauth-google-oauth2'
gem 'delayed_job_active_record'
gem 'heroku-api'
gem 'iron_worker_ng'
gem 'cancan'
gem 'redis'
gem 'rb-readline'
gem 'thin', :platforms => :ruby
gem 'prawn', "0.11.1"# , :git => "git://github.com/sandal/prawn" #, :submodules => true
#gem 'sqlite3'

#gem 'active_scaffold_config_list_vho'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'

platforms :ruby do
  gem 'pg'
end

platforms :jruby do
  gem 'jruby-openssl'
  gem 'activerecord-jdbcpostgresql-adapter'
end

group :test do
  gem 'fakeweb'
  gem 'faker', '~> 1.0.1'
  gem 'simplecov'
  gem 'capybara-webkit'
#  gem 'timecop'
end

group :development, :test do
  gem 'annotate', '~> 2.4.1.beta' 
  gem "rspec-rails"#, "2.5.0"
  gem "capybara"
  gem "guard"
  gem "guard-spork"
  gem "guard-rails"  # Restart development server when needed
  gem 'guard-rspec'
  gem "guard-annotate"
  gem 'ruby_gntp'
  gem 'launchy'
  gem 'shoulda-matchers'
  gem 'debugger', :platforms => :ruby
  gem 'ruby-debug',  :platforms => :jruby
  gem 'pry'
  gem 'pry-debugger', :platforms => :ruby  # https://github.com/nixme/pry-debugger
  gem 'pry-rails'
  gem "factory_girl"
  gem "factory_girl_rails"
  gem "selenium-client"
  gem "database_cleaner" #, :git => 'git://github.com/bmabey/database_cleaner.git'
  gem 'spork', '>= 0.9.2'
end

