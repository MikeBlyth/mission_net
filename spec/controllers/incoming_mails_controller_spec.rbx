require 'spec_helper'
include SimTestHelper
include ApplicationHelper
include IncomingMailsHelper
include MessagesHelper
  
def rebuild_message
    @params[:message] = "From: #{@params['from']}\r\n" + 
                         "To: #{@params['to']}\r\n" +
                         "Subject: #{@params['subject']}\r\n\r\n" + 
                         "#{@params['plain']}"
end

describe IncomingMailsController do
  before(:each) do
    @params = HashWithIndifferentAccess.new(
             'from' => 'member@example.com',
             'to' => 'database@sim-nigeria.org',
             'subject' => 'Test message',
             'plain' => '--content--'
             )
    rebuild_message
    ActionMailer::Base.deliveries.clear  # clear incoming mail queue
  end

  describe 'filters based on member status' do

    it 'accepts mail from SIM member (using email address)' do
      Member.stub(:find_by_email).and_return([FactoryGirl.create(:member)])
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects mail from strangers' do
      Member.stub(:find_by_email).and_return([])
      post :create, @params
      response.status.should == 403
      response.body.should =~ /refused/i
    end

  end # it filters ...

  describe 'processes' do
    before(:each) do
      controller.stub(:from_member).and_return([Member.new])   # have a contact record that matches from line
    end      
    
    it 'variety of "command" lines without crashing' do
      examples = [ 
                   "command",
                   "command and params",
                   "two\nlines",
                   "two\n\nwith blank between",
                   "command\tseparated by tab and not space",
                   ]
      examples.each do |e|
        @params['plain'] = e
        rebuild_message # needed only if the controller gets info from mail object made from params['message']
        post :create, @params
        response.status.should == 200
      end  
    end    

    it 'empty email giving error' do
      @params['plain'] = ''
      rebuild_message
      post :create, @params
      response.status.should >= 400
    end

    it 'single command on first line' do
      @params['plain'] = 'Test with parameters list'
      rebuild_message # needed only if the controller gets info from mail object made from params['message']
      post :create, @params
      response.status.should == 200
      lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
#puts ActionMailer::Base.deliveries.first.to_s
    end

    it 'commands on two lines' do
      @params['plain'] = "Test for line 1\nTest for line 2"
      rebuild_message # needed only if the controller gets info from mail object made from params['message']
      lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(2)
      response.status.should == 200
      ActionMailer::Base.deliveries.last.to_s.should =~ /line 2/
      ActionMailer::Base.deliveries.last.to_s.should match("To: #{@params['from']}")
#puts ActionMailer::Base.deliveries.last.to_s
    end

  end # processes commands

  describe 'handles these commands:' do
    before(:each) do
      controller.stub(:from_member).and_return([Member.new])   # have a contact record that matches from line
    end      
    
    describe 'info sends contact info' do

      it 'sends the email' do
        @params['plain'] = "info stranger"
        lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
      end  

      it "gives error message if name not found" do
        @params['plain'] = "info stranger"
        post :create, @params
        mail = ActionMailer::Base.deliveries.last.to_s
        mail.should =~ /no.*found/i      
      end

    end


#    describe 'directory' do
#      before(:each) {@params['plain'] = "directory"}
#      
#      it 'sends the email' do
#        lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
#        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
#      end  

#      it 'sends Where Is report as attachment' do
#        post :create, @params
#        mail = ActionMailer::Base.deliveries.last
#        attachment = ActionMailer::Base.deliveries.last.attachments.first
#        attachment.filename.should == Settings.reports.filename_prefix + 'directory.pdf'
#      end
#    end #directory
    
    describe 'help command' do
      before(:each) {@params['plain'] = "help"}
      
      it 'sends basic help info' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
        mail = ActionMailer::Base.deliveries.last.to_s.gsub("\r", "")
        mail.should match 'Accessing the SIM Nigeria Database by Email'
      end
    end #help
    
#    describe 'location' do
#      it 'sends basic help info' do
#        Contact.stub_chain(:where, :member).and_return(@member)
#        @member.should_receive(:update_attributes).with('Cannes', instance_of(Date))
#        Notifier.should_receive(:send_generic).with(/Cannes/)
#        @params['plain'] = "location Cannes"
#        post :create, @params
#      end
#    end      
    
  end # handles these commands
   
  describe 'distributes email & sms to groups' do
    before(:each) do
      @mock_message = mock_model(Message, :deliver=>true)
      Message.stub(:create).and_return(@mock_message)
      @member = FactoryGirl.build_stubbed(:member)
      controller.stub(:from_member).and_return([@member])   # have a contact record that matches from line
      @group_1 = FactoryGirl.create(:group)
      @group_2 = FactoryGirl.create(:group)
      @body = 'Test message'
      @params[:from] = 'test@test.com'
    end
    
    it '(checks setup)' do
      controller.from_member.should == [@member]
    end
    
    it 'distributes email to groups when groups are found' do
      Message.should_receive(:create).with({:send_sms=>false, :send_email=>true, 
                          :to_groups=>[@group_1.id, @group_2.id], :body=>@body})
      @params['plain'] = "email #{@group_1.abbrev} #{@group_2.abbrev}: #{@body}"
      post :create, @params
    end

    it 'distributes sms to groups when groups are found' do
      Message.should_receive(:create).with({:send_sms=>true, :send_email=>false, 
                          :to_groups=>[@group_1.id, @group_2.id], :body=>@body})
      @params['plain'] = "sms #{@group_1.abbrev} #{@group_2.abbrev}: #{@body}"
      post :create, @params
    end

    it 'distributes sms & email to groups when groups are found' do
      Message.should_receive(:create).with({:send_sms=>true, :send_email=>true, 
                          :to_groups=>[@group_1.id, @group_2.id], :body=>@body})
      @params['plain'] = "d+email #{@group_1.abbrev} #{@group_2.abbrev}: #{@body}"
      post :create, @params
    end

    it 'distributes to found groups when only some groups are found' do
      Message.should_receive(:create).with({:send_sms=>false, :send_email=>true, 
                          :to_groups=>[@group_1.id, @group_2.id], :body=>@body})
      @params['plain'] = "email badGroup #{@group_1.abbrev} sadGroup #{@group_2.abbrev}: #{@body}"
      post :create, @params
    end

    it 'creates no message when no groups are found' do
      Message.should_not_receive(:create)
      @params['plain'] = "email badGroup sadGroup: #{@body}"
      post :create, @params
    end
    
    describe 'notifies sender of results' do
      before(:each) do
        @old_notifier = Notifier
        silence_warnings {Notifier = mock('Notifier')}
        @mock_mail = mock('email', :deliver=>true)
      end
      after(:each) do
        silence_warnings {Notifier = @old_notifier}
      end
      
      it 'warns that no groups were found' do
        Notifier.should_receive(:send_generic).with(@params[:from], /no valid group/).
          and_return(@mock_mail)
        @params['plain'] = "d badGroup sadGroup: #{@body}"
        post :create, @params
      end

      it 'warns that some groups were not found' do
        Notifier.should_receive(:send_generic).with(@params[:from], 
          Regexp.new("was sent to groups #{@group_1.group_name}.* sadGroup were not found")).
          and_return(@mock_mail)
        @params['plain'] = "d badGroup sadGroup #{@group_1.abbrev} #{@group_2.abbrev}: #{@body}"
        post :create, @params
      end
      it 'warns if nothing after the "d" command' do
        Notifier.should_receive(:send_generic).with(@params[:from], 
          Regexp.new("I don't understand")).
          and_return(@mock_mail)
        @params['plain'] = "d "
        post :create, @params
      end
    end # notifies sender of results
  end # Distributes email and sms to groups
  
  describe 'handles email responses to group messages' do
    
    describe '(unique email addr)' do
      before(:each) do
        @responding_to = 25  # This is the id of the message being responded to
        @message = mock_model(Message, :deliver=>true, :process_response => nil)
        Message.stub(:find_by_id).with(@responding_to).and_return(@message)
        @member = FactoryGirl.build_stubbed(:member)
        Member.stub(:find_by_email).and_return([@member]) # Just says that this message is from a member
        @subject_with_tag = 'Re: Important ' + 
          message_id_tag(:id=>@responding_to, :location => :subject, :action=>:generate)
        @user_reply = "I'm in Kafanchan"
        @body_with_tag = message_id_tag(:id=>@responding_to, :location => :body, :action=>:confirm_tag) +
          ' ' + @user_reply
      end
      
      it 'ignores messages without msg_id reply tag' do
        @message.should_not_receive(:process_response)
        post :create, @params
      end

      it 'processes messages with msg_id in subject' do
        @params[:subject] = @subject_with_tag
        Message.should_receive(:find_by_id).with(25)
        @message.should_receive(:process_response).with(:member => @member, :text => @params['plain'], 
            :mode => 'email')
        post :create, @params
      end

      it 'processes messages with msg_id in body' do
        @params[:plain] = @body_with_tag
        Message.should_receive(:find_by_id).with(25)
        @message.should_receive(:process_response).with(:member => @member, :text => @user_reply, 
            :mode => 'email')
        post :create, @params
      end
      
    end # (unique email/phone)

    describe '(w duplicate email addr)' do

      it 'for all members having same email' do
        @message = Message.create(:send_email=>true, :to_groups => '1', :body => 'test')
        @member_1 = FactoryGirl.create(:member)  # handy if not most efficient way to make a member with a contact
        @member_2 = FactoryGirl.create(:member, :email_1 => @member_1.email_1) 
        @message.members << [@member_1, @member_2]
        @params['plain'] = "!#{@message.id}"  # e.g. #24 if @message.id is 24
        @params['from'] = @member_1.primary_email
        post :create, @params
        @message.sent_messages.each {|sm| sm.msg_status.should == MessagesHelper::MsgResponseReceived}
      end
    end # (w duplicate email addr)
  end #    handles email responses to group messages   
end
