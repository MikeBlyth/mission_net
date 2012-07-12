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

    it 'accepts mail from SIM member (using email_1)' do
      @contact = Factory(:contact, :email_1 => @params['from'])  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'accepts mail from SIM member (using email_2)' do
      @contact = Factory(:contact, :email_2 => @params['from'])  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'accepts mail from SIM member (stubbed)' do
      controller.stub(:from_member).and_return([Member.new])  # have a contact record that matches from line
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects mail from strangers' do
      @contact = Factory(:contact, :email_1=> 'stranger@example.com')  # have a contact record that matches from line
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
      contact_type = Factory(:contact_type)
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

      it "sends basic info if contact record not found" do
        member = Factory(:member, :last_name=>'Jehu')
        @params['plain'] = "info Jehu"
        post :create, @params
        mail = ActionMailer::Base.deliveries.last.to_s
        mail.should =~ /Jehu/
        mail.should =~ /no contact/i
      end

      it "includes all relevant info for couple" do
        member = create_couple
        residence_location = Factory(:location, :description=>'Rayfield')
        work_location = Factory(:location, :description=>'Spring of Life')
        member.update_attributes(:birth_date => Date.new(1980,6,15),
#*                     :residence_location=>residence_location,
                     :work_location=>work_location,
                     :temporary_location => 'Miango Resort Hotel',
                     :temporary_location_from_date => Date.today - 10.days,
                     :temporary_location_until_date => Date.today + 2.days,
                     )
                     
        contact = Factory :contact, :member => member
        contact_spouse = Factory :contact, :member => member.spouse, 
                    :email_1 => 'spouse@example.com',
                    :email_2 => 'josette@gmail.com',
                    :phone_2 => '0707-777-7777',
                    :skype => 'Josette', :skype_private => false,
                    :blog => 'http://josette.blogspot.com',
                    :photos => 'http://myphotos.photos.com'
        other = Factory :family, :last_name => 'Finklestein'
        @params['plain'] = "info #{member.last_name}"
        post :create, @params
        mail = ActionMailer::Base.deliveries.last.to_s
        required_contents = [member.residence_location, member.work_location, member.temporary_location,
             member.last_name, member.first_name, member.primary_contact.email_1, member.birth_date.to_s(:short),
             contact_spouse.email_1, contact_spouse.email_2, 
             format_phone(contact_spouse.phone_1), format_phone(contact_spouse.phone_2),
             contact_spouse.skype,  contact_spouse.blog, contact_spouse.photos,
             ]
        required_contents.each do |target|
          mail.should =~ Regexp.new(target.to_s)
        end
        mail.should_not match 'Finklestein'
      end    # example

      describe 'info marked as private' do

        it 'is hidden to 3rd party' do
     #     requestor = Factory(:family).head  # This is the person mailing in the request
     #     requestor_contact = Factory(:contact, :member=>requestor) # must have contact info in DB or will not recieve reply
          member = Factory(:member)     # This is the person for whom info is being requested
          contact = Factory(:contact, :member => member, 
                      :email_1 => 'member2@example.com',
                      :email_2 => 'secondary@gmail.com',
                      :phone_2 => '0707-777-7777',
                      :phone_1 => '0807-777-7777',
                      :skype => 'MySkype',
                      :skype_private => true, # phone, email and skype are all marked as private
                      :email_private => true,
                      :phone_private => true,
                      :blog => 'http://josette.blogspot.com',
                      :photos => 'http://myphotos.photos.com')
     #     @params['from'] = requestor_contact.email_1 # set up @params with requestor email and the request itself
          @params['plain'] = "info #{member.last_name}"
          post :create, @params
          mail = ActionMailer::Base.deliveries.last.to_s
          # None of these should be found as they're all marked private
          [:email_1, :email_2, :skype].each do |field|
            mail.should_not match(contact[field])
          end 
          [:phone_1, :phone_2].each do |field|
            mail.should_not match Regexp.new("#{contact[field].phone_format}.*private")
          end
          mail.should match(contact[:photos])          
        end # hides contact info marked as private     
      
        it 'is shown when requested by same member' do
          member = Factory(:member)
          controller.stub(:from_member).and_return([member])   # indicate that mail originates from same member as being requested
          contact = Factory(:contact, :member => member, 
                      :email_2 => 'secondary@gmail.com',
                      :phone_2 => '0707-777-7777'.phone_format,
                      :phone_1 => '0807-777-7777'.phone_format,
                      :skype => 'MySkype',
                      :skype_private => true,
                      :email_private => true,
                      :phone_private => true,
                      :blog => 'http://josette.blogspot.com',
                      :photos => 'http://myphotos.photos.com')
          @params['plain'] = "info #{member.last_name}"
          post :create, @params
          mail = ActionMailer::Base.deliveries.last.to_s
          [:email_1, :email_2, :skype].each do |field|
            mail.should =~ Regexp.new("#{contact[field]}.*private")
          end
          [:phone_1, :phone_2].each do |field|
            mail.should =~ Regexp.new("#{contact[field].phone_format}.*private")
          end
          mail.should match(contact[:photos])          
        end # is shown when requested by same member 

      end # info marked as private
      
    end # info
    
    describe 'directory' do
      before(:each) {@params['plain'] = "directory"}
      
      it 'sends the email' do
        lambda{post :create, @params}.should change(ActionMailer::Base.deliveries, :length).by(1)
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
      end  

      it 'sends Where Is report as attachment' do
        post :create, @params
        mail = ActionMailer::Base.deliveries.last
        attachment = ActionMailer::Base.deliveries.last.attachments.first
        attachment.filename.should == Settings.reports.filename_prefix + 'directory.pdf'
      end
    end #directory
    
    describe 'travel' do
      before(:each) {@params['plain'] = "travel"}
      
      it 'sends the email' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
      end  

      it 'sends travel schedule as attachment' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        mail = ActionMailer::Base.deliveries.last
        attachment = ActionMailer::Base.deliveries.last.attachments.first
        attachment.filename.should == Settings.reports.filename_prefix + 'travel_schedule.pdf'
      end
    end #directory
    
    describe 'birthday list' do
      before(:each) {@params['plain'] = "birthdays"}
      
      it 'sends birthday list as attachment' do
        post :create, @params
        ActionMailer::Base.deliveries.length.should == 1
        ActionMailer::Base.deliveries.last.to.should == [@params['from']]
        attachment = ActionMailer::Base.deliveries.last.attachments.first
        attachment.filename.should == Settings.reports.filename_prefix + 'birthdays.pdf'
      end
    end #birthdays
    
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
      @member = Factory.stub(:member)
      controller.stub(:from_member).and_return([@member])   # have a contact record that matches from line
      @group_1 = Factory(:group)
      @group_2 = Factory(:group)
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
        @member = Factory.stub(:member)
        Member.stub(:find_by_email).and_return([@member]) # Just says that this message is from a member
        contact = mock('contact', :member => @member)
        Contact.stub(:where).and_return([contact])   # have a contact record that matches from line
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
        @member_1 = Factory(:contact).member  # handy if not most efficient way to make a member with a contact
        @member_2 = Factory(:contact).member
        @message.members << [@member_1, @member_2]
        @params['plain'] = "!#{@message.id}"  # e.g. #24 if @message.id is 24
        @params['from'] = @member_1.primary_email
        post :create, @params
        @message.sent_messages.each {|sm| sm.msg_status.should == MessagesHelper::MsgResponseReceived}
      end
    end # (w duplicate email addr)
  end #    handles email responses to group messages   
end
