require 'rubygems'
require 'spork'

#***** REMEMBER TO RESTART SPORK AFTER CHANGING THIS FILE! **

################  SPORK ########################
#uncomment the following line to use spork with the debugger
require 'spork/ext/ruby-debug'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.
puts "**** SPORK LOADING PREFORK"

####  Load simplecov here if *not* running under spork
  unless ENV['DRB']
    require 'simplecov'
    SimpleCov.start 'rails'
  end

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    #config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false
    
    config.include FactoryGirl::Syntax::Methods
  end

  # Define a helper to directly sign in a test user
#  def test_sign_in(user)
#    controller.sign_in(user)
#  end

  def test_sign_in(role=:administrator)
    group = FactoryGirl.build_stubbed(:group, role => true)
    @user = FactoryGirl.build_stubbed(:member, :groups => [group], :id => 999)
    controller.stub(:current_user).and_return(@user)
    return @user
  end
  alias test_sign_in_fast test_sign_in

  def test_sign_out
    controller.sign_out
  end

  def create_signed_in_member(role=:member)
    group = FactoryGirl.create(:group, role => true)
    @user = FactoryGirl.create(:member, :groups => [group])
    controller.stub(:current_user).and_return(@user)
    return @user
  end

  def integration_test_sign_in(role=:administrator)
    if role.to_s.downcase == 'none'
      user = FactoryGirl.create(:member, :name=>'test', :email_1 => 'testemail')
    else
      role_group = FactoryGirl.create(:group, role => true)
      user = FactoryGirl.create(:member, :name=>'test', :groups => [role_group], :email_1 => 'testemail')
    end
#puts "****user created, user.id=#{user.id}"
    visit sign_out_path # log out previous user
    visit create_test_session_path
  end
     

  def integration_test_sign_in_old(options={})
      @user = Factory.create(:user, options)
      visit signin_path
      fill_in "Name",    :with => @user.name
      fill_in "Password", :with => @user.password
      click_button "Sign in"
  end



  load 'sim_test_helper.rb'
#  load 'messages_test_helper.rb'
#  load 'secret_credentials.rb'
end  

Spork.each_run do
  puts "**** SPORK LOADING EACH RUN"
  load 'clickatell_gateway.rb'  # Why does it have to be specified??
  # Run simplecov here if we *are* running under spork (ENV['DRB'])
#  if ENV['DRB']
#    require 'simplecov'
#    SimpleCov.start 'rails'
#  end

# This code will be run each time you run your specs.
end



