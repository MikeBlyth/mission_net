require 'spec_helper'
include SimTestHelper
#include ApplicationHelper
require 'messages_test_helper.rb' 
include MessagesTestHelper  

describe SmsController do
# Incoming SMS Text Messages


  before(:each) do
    # Intercept Internet calls so we don't actually call SMS gateway
    AppLog.stub(:create)
    @gateway = MockClickatellGateway.new
    ClickatellGateway.stub(:new).and_return(@gateway)
#    silence_warnings {AppLog = double('AppLog').as_null_object}
    # Target -- the person being inquired about in info command
    @target = FactoryGirl.build_stubbed(:member, :last_name=>'Target')  # Request is going to be for this person's info
    @sender = FactoryGirl.build_stubbed(:member)
    @sender.stub(:shorter_name).and_return('V Anderson')
#    Member.stub(:find_by_phone).and_return([@sender])
    @from = '+2348030000000'  # This is the number of incoming SMS
    @body = "info #{@target.last_name}"
    @params = {:From => @from, :Body => @body}
  end
    
  describe 'logging' do

    describe 'accepted messages' do
      before(:each) do
       # Contact.stub(:find_by_phone_1).and_return(true)
       Member.stub(:find_by_phone).and_return([@sender])
      end
      
      it 'creates a log entry for SMS received' do
        AppLog.should_receive(:create).with({:code => "SMS.received", :description=>"from #{@from} (#{@sender.shorter_name}): #{@body}"})
        post :create, @params
      end      

      it 'creates a log entry for response' do
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.reply"))
        post :create, @params
      end      
    end
    
    describe 'rejected messages' do
      it 'creates a log entry for rejected incoming SMS' do
        Member.stub(:find_by_phone).and_return([])
        AppLog.should_receive(:create).with(hash_including(:code => "SMS.rejected"))
        post :create, @params
      end
    end      

  end # logging
  
  describe 'filters based on member status' do

    it 'accepts sms from member (using phone_1)' do
      Member.stub(:find_by_phone).and_return([@sender])
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects sms from strangers' do
      Member.stub(:find_by_phone).and_return([])
      post :create, @params
      response.status.should == 403
    end

  end # it filters ...


  describe 'handles these commands:' do
    before(:each) do
  #    controller.stub(:from_member).and_return(Member.new)   # Just a shortcut to have a contact record that matches from line
      Member.stub(:find_by_phone).and_return([@sender])
    end      

    describe "'info'" do

      describe 'when target name not found' do
        it "gives error message" do
          Member.stub(:find_with_name).and_return([])
          @params[:Body] = "info stranger"
          post :create, @params
          response.body.should =~ /no.*found/i      
          response.body.should =~ /stranger/i      
        end
      end

      describe 'when name found' do  # record for requested name is found
        before(:each) do
          @last_name = "Abcde"
          @target = FactoryGirl.build_stubbed(:member, :last_name=>@last_name,
          :phone_2=>"+2348079999999", :email_2 => 'something@example.com'
                       )
          @params[:Body] = "info #{@last_name}"
          Member.stub(:find_with_name).and_return([@target])
        end
                          
        it "sends contact info and location" do
          post :create, @params
          response.body.should match @last_name
          response.body.should match Regexp.escape(@target.phone_1.phone_format)
          response.body.should match Regexp.escape(@target.phone_2.phone_format)
          response.body.should match Regexp.escape(@target.email_1)
          response.body.should_not match Regexp.escape(@target.email_2)
        end

        it 'does not send phone number if marked as private' do
          @target.phone_private=true
          post :create, @params
          response.body.should match Regexp.escape(@target.email_1)
          response.body.should_not match Regexp.escape(@target.phone_1.phone_format)
          response.body.should_not match Regexp.escape(@target.phone_2.phone_format)
        end

        it 'does not send email if marked as private' do
          @target.email_private=true
          post :create, @params
          response.body.should match Regexp.escape(@target.phone_1.phone_format)
          response.body.should_not match Regexp.escape(@target.email_1)
          response.body.should_not match Regexp.escape(@target.email_2)
        end

      end # when name and

      it 'limits response length to 160 chars' do
        @params['Body'] = "info #{'a'*170}"
        post :create, @params
        response.body.length.should < 161
      end     

    end # 'info sends contact info'

    describe 'd (group deliver)' do
      before(:each) do
        @body = 'xtest messagex'
        @group_name = 'testgroup'
        @params['Body'] = "d #{@group_name} #{@body}"
        @message = Message.new
      end
      
      describe 'when group is found' do
        before(:each) do
          
          @httyparty = HTTParty
          silence_warnings{HTTParty = mock('HTTParty')}
          @group = FactoryGirl.create(:group, :group_name=>@group_name)
        end
        after(:each) do       
          silence_warnings{HTTParty = @httyparty}
        end
             
       it 'delivers a group message' do
          nominal_body = @body+"-#{@sender.shorter_name}"
          Message.should_receive(:new).with(hash_including(:user_id => @sender.id,
              :send_sms=>true, :to_groups=>@group.id, :sms_only=>nominal_body)).and_return(@message)
          @message.should_receive(:deliver)              
          post :create, @params   # i.e. sends 'd testgroup test message'
        end

        it 'confirms to sender' do
          post :create, @params   # i.e. sends 'd testgroup test message'
          response.body.should match /your message.*is being sent/i
        end
      end # 'when group is found'
      
      describe 'when group is not found' do
        before(:each) { @params['Body'] = "d bad_group #{@body}"}
        it 'does not deliver a group message' do
          nominal_body = @body+"-#{@sender.shorter_name}"
          Message.should_not_receive(:new)
          post :create, @params   # i.e. sends 'd testgroup test message'
        end

        it 'informs sender of error' do
          post :create, @params   # i.e. sends 'd testgroup test message'
          response.body.should match /error.*bad_group/i
        end
      end # 'when group is found'
      
    end # d (group deliver)
    
    describe 'help' do
      before(:each) do
      end
      
      it 'responds to help by itself' do
        @params['Body'] = "help"
        post :create, @params   
        response.body.should match /get contact info/
      end
      it 'responds to ? by itself' do
        @params['Body'] = "?"
        post :create, @params   
        response.body.should match /get contact info/
      end
    end  # help
    
    describe 'groups' do
      
      it 'returns a list of primary groups' do
        Group.stub(:primary_group_abbrevs).and_return('cat dog zebrafish')
        @params['Body'] = 'groups'
        post :create, @params   
        response.body.should  =~ /cat dog zebrafish/
      end
    end
 
    describe 'updates' do
      before(:each) do
        @update = mock_model(Message).as_null_object
      end
     
      it 'returns the latest news update' do
        Message.stub(:news_updates => [@update])
        @update.should_receive(:deliver_sms).with(:phone_numbers => @from, :news_update=>true)
        @params['Body'] = "updates"
        post :create, @params   
        response.body.should match /sending 1 update/i
      end

      it 'returns all the latest news updates' do  # sends all that are returned by Message#news_updates
        Message.stub(:news_updates => [@update, @update, @update])
        @params['Body'] = "updates"
        @update.should_receive(:deliver_sms).with(:phone_numbers => @from, :news_update=>true).exactly(3).times
        post :create, @params   
        response.body.should match /sending 3 updates/i
      end
      
      it 'forwards keywords to Message#news_update' do
        Message.should_receive(:news_updates).with(hash_including(:keyword => 'key')).and_return [@update]
        @params['Body'] = "updates key"
        post :create, @params   
      end         

      it 'forwards limit to Message#news_update' do
        Message.should_receive(:news_updates).with(hash_including(:limit => 5)).and_return [@update]
        @params['Body'] = "updates 5"
        post :create, @params   
      end         

      it 'forwards limit-keyword mix to Message#news_update' do
        Message.should_receive(:news_updates).with(hash_including(:limit => 5, :keyword => 'key')).and_return [@update]
        @params['Body'] = "updates 5 key"
        post :create, @params   
      end         

      it 'forwards keyword-limit mix to Message#news_update' do
        Message.should_receive(:news_updates).with(hash_including(:limit => 5, :keyword => 'key')).and_return [@update]
        @params['Body'] = "updates key 5"
        post :create, @params   
      end         

      it 'sends last update if keyword search fails Message#news_update' do
        Message.should_receive(:news_updates).with(hash_including(:limit => 5, :keyword => 'key')).and_return []
        Message.should_receive(:news_updates).with(hash_including(:limit => instance_of(Fixnum))).and_return [@update]
        @params['Body'] = "updates key 5"
        post :create, @params   
      end         

    end  
#    describe 'location' do
#      before(:each) {Time.stub(:now).and_return Time.new(2000,01,01,12,00)}

#      it 'sets member location' do
#        #  def update_reported_location(text, reported_location_time=Time.now, expires=Time.now+DefaultReportedLocDuration*3600)
#        @sender.should_receive(:update_reported_location).with('Cannes', Time.now, Time.now+DefaultReportedLocDuration*3600)
#        @params['Body'] = 'location Cannes'
#        post :create, @params
#      end

#      it 'sets member location w duration' do
#        @sender.should_receive(:update_reported_location).with('Cannes', Time.now, Time.now+6.hours)
#        @params['Body'] = 'location Cannes 6'
#        post :create, @params
#      end

#      it 'sets member location w duration long format' do
#        @sender.should_receive(:update_reported_location).with('Cannes', Time.now, Time.now+6.hours)
#        @params['Body'] = 'location Cannes for 6 hours'
#        post :create, @params
#      end

#      it 'sets member location "location at Cannes for 6"' do
#        @sender.should_receive(:update_reported_location).with('Cannes', Time.now, Time.now+6.hours)
#        @params['Body'] = 'location at Cannes for 6'
#        post :create, @params
#      end

#    end  

  end # 'handles these commands:'

  # If an SMS is received from someone who has been _sent_ a message within a time frame, 
  # assume that this is a reply to that message. For now, just assume it's replying to the last message the user received.
  describe 'handles untagged replies' do
    before(:each) do
      @group = FactoryGirl.create(:group)
      @sender = FactoryGirl.create(:member, :last_name => 'Responder')
      @body = 'Unsolicited response'
      @params = {:From => @sender.phone_1, :Body => @body}
    end
    
    describe 'when no recent message was sent' do

      it 'returns error for unrecognized command' do
        post :create, @params
        response.body.should =~ /unknown .*unsolicited/i
      end
        
    end # when no recent message was sent
    
    describe 'when recent message was sent' do
      before(:each) do
        # Create a message in the DB, which had been delivered by @moderator to a group including @sender of this unsolicited reply
        @moderator = FactoryGirl.create(:member, :last_name => 'Moderator')
        @sender.groups = [@group]
        @message = FactoryGirl.create(:message, :user_id => @moderator.id, :send_sms => true, :to_groups => @group.id.to_s)
      end
          
      it 'test setup' do
        @message.deliver
        @sender.messages.should == [@message]  # Just checking that our setup is OK, with sender having recent message
      end

      it 'confirms forwarding' do
        Member.stub(:find_by_phone).and_return([@sender])
        @message.deliver
        post :create,  {:From => @sender.phone_1, :Body => 'Unsolicited response'}  # @sender delivers a message to the system
        response.body.should match "forwarded to .*#{@moderator.last_name}"
      end
      
      it 'replies to last message' do
        Member.stub(:find_by_phone).and_return([@sender])
        @gateway = mock('Gateway')
        @gateway.should_receive(:deliver).with(@moderator.phone_1, Regexp.new("#{@sender.last_name}.*#{@body}"))
        @message.deliver
        SmsGateway.stub(:default_sms_gateway => @gateway)
        post :create,  {:From => @sender.phone_1, :Body => 'Unsolicited response'}  # @sender delivers a message to the system
      end
    end     # when recent message was sent
  end

  describe 'handles responses to messages' do
    # Responses are indicated by a command '!nnnn' where nnnn is the message number
    before(:each) do
    end

    it 'updates status of sent_message record' do
      # We have to set up a message that the incoming SMS is responding to
      @message = FactoryGirl.build_stubbed(:message, :send_email => true)
      Message.stub(:find_by_id).and_return(@message)
      Member.stub(:find_by_phone).and_return([@sender])
      # When a response is received, the sent_message corresponding to the message & user
      #   should be updated to show that it was responded to
      @params['Body'] = "!#{@message.id}"  # e.g. #24 if @message.id is 24
      @message.should_receive(:process_response)
      post :create, @params
    end               

    it 'for all members having same phone number' do
      @message = Message.create(:send_email=>true, :to_groups => '1', :body => 'test')
      @member_1 = FactoryGirl.create(:member)  # handy if not most efficient way to make a member with a contact
      @member_2 = FactoryGirl.create(:member)
      @message.members << [@member_1, @member_2]
      @params['Body'] = "!#{@message.id}"  # e.g. #24 if @message.id is 24
      @params['From'] = @member_1.primary_phone
      post :create, @params
      @message.sent_messages.each {|sm| sm.msg_status.should == MessagesHelper::MsgResponseReceived}
    end

  end # handles responses to messages         

end
