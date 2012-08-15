require "spec_helper"
require 'sim_test_helper'
include SimTestHelper
include NotifierHelper

describe Notifier do
    let(:sixpm) {Time.new(2010,1,1,18,0,0)}    
    let(:twopm) {Time.new(2010,1,1,14,0,0)}    
#  ## NB! Using a before(:all) which can cause dependency problems if anything defined in this
#  ##   block is changed directly or indirectly by examples. ContactType is defined so that
#  ##   contact records have a valid type (without having to define it each time) and there
#  ##   is no reason to change any ContactType records in this test suite. 
#  before(:all) do 
#    Factory :contact_type
#  end

  # TODO: this partly duplicates tests found in admin controller
  # Need to rationalize division of mailer tests between controllers and mailer.

  describe "send_generic" do
    
    it 'normally sets To: field' do
      mail = Notifier.send_generic("test@example.com",'body')
      mail.to.should == ["test@example.com"]
      mail.bcc.should be_empty
    end
    it 'sets Bcc: field and not To: if bcc is selected' do
      mail = Notifier.send_generic("test@example.com",'body', true)
      mail.bcc.should == ["test@example.com"]
      mail.to.should be_empty
    end
  end

  describe 'send member summary' do
    before(:each) do 
      @member = FactoryGirl.create(:member, :country => nil)
    end
    
    it 'creates a summary for a family' do
      message = Notifier.send_member_summary(@member)
      message.to_s.should match summary_header[0..20]
    end
# 
#    # The _contents_ of the summary are tested without having to invoke mailer
#    it 'includes all specified information' do
#      summary = member_summary_content(@member)
#      summary.should_not be_nil
#      m = @member
#      required_fields = [
#         m.last_name, m.first_name, m.email_1,  m.email_2, 
#         m.phone_private, m.email_private, m.location, m.location_detail,
#         m.arrival_date, m.departure_date, m.groups
#         ]
#         
#      required_fields.each do |field| 
#        summary.should match(Regexp.escape(field.to_s)) 
#      end  
#      summary.should match c.phone_1.phone_format
#      summary.should match c.phone_2.phone_format
#    end            

#  describe "contact updates" do
#    before(:each) do
#      @member = Factory.stub(:member)
#      @contact = Factory.stub(:contact, :member=>@member, :updated_at=>Time.now)
#      @member.stub(:contacts).and_return([@contact])
#    end

#    it "includes contact name" do
#      message = Notifier.contact_updates('mike@example.com', [@contact])
##puts "message => #{message}"
#      message.to_s.should match @member.last_name
#    end

#    it "includes contact email" do
#      message = Notifier.contact_updates('mike@example.com', [@contact])
#      message.to_s.should match @contact.email_1
#    end

#    it "includes message if there are no updates" do
#      message = Notifier.contact_updates('mike@example.com', [])
#      message.to_s.should match "No changes"
#    end
  end  # Contact updates

#  describe 'group_message' do
#    before(:each) do
#      @message_id = 25
#      @response_time_limit = 15
#      @params = {:recipients => ['mike@example.com'], :content => 'Test message', 
#        :subject => "Test Subject Line", :id => @message_id, 
#        :response_time_limit => @response_time_limit, :bcc => true} 
#    end

#    it 'adds tag to subject line' do
#      email = Notifier.send_group_message(@params)
#      email.subject.should =~ Regexp.new(@message_id.to_s)
#    end
#    
#    it 'includes response info when response_time_limit > 0' do
#      email = Notifier.send_group_message(@params)
#      email.to_s.should =~ /The sender has requested/
#    end

#    it 'includes does not include response info when response_time_limit > 0' do
#      email = Notifier.send_group_message(@params.merge(:response_time_limit => nil))
#      email.to_s.should_not =~ /The sender has requested/

#    end
#  end
end
