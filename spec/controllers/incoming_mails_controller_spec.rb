require 'spec_helper'
include SimTestHelper
include ApplicationHelper
include IncomingMailsHelper
include MessagesHelper
require 'openssl'
require "base64"
require "timecop"

ActionMailer::Base.delivery_method.should == :test
  
def rebuild_message
    @params[:message] = "From: #{@params['from']}\r\n" + 
                         "To: #{@params['to']}\r\n" +
                         "Subject: #{@params['subject']}\r\n\r\n" + 
                         "#{@params['plain']}"
end


def test_sender(role=nil)
  member = FactoryGirl.build_stubbed(:member)
  member.stub(:role => role) if role   # Role needed for some tests and not others
  controller.stub(:login_allowed => member)
  Member.stub(:find_by_email => [member])
  return member
end  

def add_member_string(member)
  "#{member.first_name} #{member.last_name} #{member.phone_1} #{member.phone_2} " +
  "#{member.email_1} #{member.email_2} " +
  member.groups.map {|g| g.abbrev}.join(' ')
end

# Directly access the controller's validation_string method
# This also sets @from_address in the controller to email_address, so
# subsequent testing of checking validation string will expect to see
# email_address in the encrypted validation string
def create_validation_string(email_address)
  controller.instance_variable_set(:@from_address, email_address)
  return controller.validation_string
end

describe IncomingMailsController do
  let(:mail_queue) {ActionMailer::Base.deliveries}
  let(:mail) {ActionMailer::Base.deliveries.last.to_s.gsub("\r", "")}
  let(:mail_destination) {mail_queue.last.to}
  let(:mail_subject) {mail_queue.last.subject}
  before(:each) do
    @params = HashWithIndifferentAccess.new(
             'from' => 'member@example.com',
             'to' => 'database@sim-nigeria.org',
             'subject' => 'Test message',
             'plain' => '--content--'
             )
    rebuild_message
    mail_queue.clear  # clear incoming mail queue
    @mock_message = mock_model(Message, :deliver=>true)
  end

  describe 'filters based on member status' do

    it 'accepts mail from member (using email address)' do
      test_sender
      post :create, @params
      response.status.should == 200
    end
    
    it 'rejects mail from strangers' do
      controller.stub(:login_allowed => false)
      post :create, @params
      response.status.should == 403
      response.body.should =~ /refused/i
    end

  end # it filters ...

  describe 'processes' do
    before(:each) do
      test_sender  # Set up valid sender of email (but with no roles)
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
      lambda{post :create, @params}.should change(mail_queue, :length).by(1)
    end

    it 'commands on two lines' do
      @params['plain'] = "Test for line 1\nTest for line 2"
      lambda{post :create, @params}.should change(mail_queue, :length).by(2)
      response.status.should == 200
      mail.should =~ /line 2/
      mail_destination.should == [@params['from']]
#puts ActionMailer::Base.deliveries.last.to_s
    end

  end # processes commands

  describe 'handles these commands:' do
    before(:each) do
      @sender = test_sender  # Set up valid sender of email (but with no roles)
    end      
    
    describe 'INFO command sends contact info' do

      it 'sends the email' do
        @params['plain'] = "info stranger"
        lambda{post :create, @params}.should change(mail_queue, :length).by(1)
#puts "**** mail_destination=#{mail_destination}"
        mail_destination.should == [@params['from']]
      end  

      it "gives error message if name not found" do
        @params['plain'] = "info stranger"
        post :create, @params
        mail.should =~ /no.*found/i      
      end

    end

    describe 'HELP command' do
      before(:each) {@params['plain'] = "help"}
      
      it 'sends basic help info' do
        post :create, @params
        mail_queue.length.should == 1
        mail_destination.should == [@params['from']]
        mail.should match 'Accessing the .* Database by Email'
      end
    end #help
    
    # Needs to be refactored to DRY this with CHANGE
    describe 'ADD command' do
      let(:new_member) {FactoryGirl.build(:member)}
      let(:command_string) { "add #{add_member_string(new_member)}"}

      it 'authorizes a sender who is a moderator' do
        @params['plain'] = command_string
        sender = test_sender(:moderator)
        post :create, @params
        mail.should match 'Validation'
      end

      it 'does not a sender who is not a moderator' do
        @params['plain'] = command_string
        sender = test_sender(:member)
        post :create, @params
        mail.should match 'not authorized'
      end

      # With a validated request, the new name should be added if it is still unique
      context 'when sender is authorized' do
        before(:each) { controller.stub(:create_authorized? => true)}

        it 'sends rest of line to Member.parse_update_command' do
          Member.should_receive(:parse_update_command).with("xxxxx vvvvv").
            and_return({:members=>[], :updates=>{}}) # just returns empty hash
          @params['plain'] = "add xxxxx vvvvv"
          post :create, @params
        end
        # Now since Member#parse_update_command is tested separately, we can
        # just stub its responses to make sure ADD responds appropriately

        context 'incoming email is validated' do
          before(:each) do 
            vstring = create_validation_string(@params[:from])
            @params['plain'] = "#{command_string}\n\n#{vstring}"  # add validation
          end

          context 'when name is still unique' do
            it 'adds the member and sends confirming message' do
              lambda{post :create, @params}.should change(Member, :count).by(1)
              mail_subject.should match 'Confirming'
  #  puts "**** mail=#{mail}"
            end
          end
          
          context 'when name has been taken' do
    
            it 'returns an error message' do
              new_member.save.should be_true  # Create record with name
#  puts "**** posted @params=#{@params}"
              lambda{post :create, @params}.should change(mail_queue, :length).by(1)
              mail_destination.should == [@params['from']]
              mail.should match 'That name already exists'
              mail.should match new_member.last_name
            end
          end

          context 'when record is invalid on save' do
    
            it 'returns an error message' do
              new_member.errors.add(:name, 'Too silly')
              new_member.errors.add(:phone, 'Too short')
              new_member.stub(:save => nil) # in case the save rather than create method is used
              new_member.stub(:valid? => false)
              Member.should_receive(:create).and_return(new_member) # simulate error on create
              lambda{post :create, @params}.should change(mail_queue, :length).by(1)
              mail_destination.should == [@params['from']]
              mail.should match 'Too silly'
              mail.should match 'Too short'
            end
          end
        end # 'incoming email is validated'
      
        context 'when incoming email is not validated' do
          before(:each) {@params['plain'] = command_string}

          context 'when everything is right' do
            it 'returns verification request' do
#puts "**** @params=#{@params}"
              lambda{post :create, @params}.should change(mail_queue, :length).by(1)
              mail.should match 'Validation: '
            end
          end
          
          context 'when name is taken' do
            it 'returns an error message' do
              new_member.save.should be_true  # save so the email add command will be a duplicate
              lambda{post :create, @params}.should change(mail_queue, :length).by(1)
              mail.should_not match 'Validation: '
              mail.should match 'already exists'
            end
          end
          
        end # when incoming email is not validated
      end # when sender is authorized
    end # ADD command

    describe 'CHANGE command' do
      let(:target) {mock_model(Member)}
      let(:target_2) {mock_model(Member)}

      let(:good_response) { {:members => [target], :updates => {:phone_1 => '123', :email_1 => 'a@b.test'}}}
      let(:double_response) { {:members => [target, target_2], :updates => {:phone_1 => '123', :email_1 => 'a@b.test'}}}

      before(:each) { @params['plain'] = "update xxxxx vvvvv"}

      it 'sends rest of line to Member#parse_update_command' do
        Member.should_receive(:parse_update_command).with("xxxxx vvvvv")
        @params['plain'] = "update xxxxx vvvvv"
        post :create, @params
      end

      # Now since Member#parse_update_command is tested separately, we can
      # just stub its responses to make sure CHANGE responds appropriately
      context 'a single member matches request' do
        context 'incoming email is validated' do
          before(:each) do 
            vstring = create_validation_string(@params[:from])
            @params['plain'] = "update xxxxx vvvvv\n\n#{vstring}"  # include validation
          end

          context 'sender is a moderator' do
            before(:each) do 
              @sender.stub(:role => :moderator)
              Member.should_receive(:parse_update_command).and_return(good_response)
            end

            context 'updates are successful' do
              it 'updates record ' do
                target.should_receive(:update_attributes).with(hash_including (
                   {:phone_1 => '123',
                    :email_1 => 'a@b.test'}) )
                post :create, @params
              end

              it 'sends confirmatory email' do
                target.stub(:update_attributes).and_return true
                target.stub(:name).and_return("Some name")
                lambda{post :create, @params}.should change(mail_queue, :length).by(1)
                mail_destination.should == [@params['from']]
                mail.should match 'Successful updates'
                mail.should match 'Some name'
              end
            end #updates are successful
 
            context 'updates are unsuccessful' do
              it 'returns an error message' do
                target.stub(:update_attributes).and_return false
                target.stub_chain(:errors, :full_messages => ['You forgot something'])
                lambda{post :create, @params}.should change(mail_queue, :length).by(1)
                mail_destination.should == [@params['from']]
                mail.should match 'You forgot something'
              end
            end # updates are unsuccessful  
          end # sender is a moderator

          context 'sender is not a moderator' do
            before(:each) {@sender.stub(:role => :member)}

            context 'but trying to change some record' do
              before(:each) {Member.should_receive(:parse_update_command).and_return(good_response)}

              it 'does not update other record' do
                target.should_not_receive(:update_attributes)
                post :create, @params
              end

              it 'sends error email' do
                post :create, @params
                mail.should match 'Only moderators'
              end
            end # but trying to change some record

            context 'but trying to change own record' do
              before(:each) do
                Member.should_receive(:parse_update_command).
                  and_return({:members => [@sender], :updates => {:phone_1 => '123'}})
              end

              it "does update sender's own record" do
                @sender.should_receive(:update_attributes)
                post :create, @params
              end

              it "sends confirmation email" do
                @sender.should_receive(:update_attributes).and_return(true)
                post :create, @params
                mail.should match 'Successful updates'
                mail.should match @sender.name
              end
            end # 'but trying to change own record'
          end # sender is not a moderator
        end # 'incoming email is validated'

        context 'incoming email is not validated' do
          context 'sender is a moderator' do
            before(:each) do 
              @sender.stub(:role => :moderator)
              Member.should_receive(:parse_update_command).and_return(good_response)
            end

            it 'does not update record' do
              target.should_not_receive(:update_attributes)
              post :create, @params
            end

            it 'sends validation email' do
              target.stub(:name).and_return("Some name")
puts "**** @params=#{@params}"
              lambda{post :create, @params}.should change(mail_queue, :length).by(1)
              mail_destination.should == [@params['from']]
              mail.should match @params['plain'] # original command(s) should be included
              mail.should match 'These changes will be made'
              mail.should match 'Some name'
              mail.should match 'Validation: '
puts "**** mail=#{mail}"
            end
          end # sender is a moderator

          context 'sender is not a moderator' do
            before(:each) {@sender.stub(:role => :member)}

            context 'but trying to change some record' do
              before(:each) {Member.should_receive(:parse_update_command).and_return(good_response)}

              it 'does not update other record' do
                target.should_not_receive(:update_attributes)
                post :create, @params
              end

              it 'sends error email' do
                post :create, @params
                mail.should match 'Only moderators'
              end
            end # but trying to change some record

            context 'but trying to change own record' do
              before(:each) do
                Member.should_receive(:parse_update_command).
                  and_return({:members => [@sender], :updates => {:phone_1 => '123'}})
              end

              it "does not update sender's own record" do
                @sender.should_not_receive(:update_attributes)
                post :create, @params
              end

              it "sends validation email" do
                @sender.should_not_receive(:update_attributes)
                post :create, @params
                mail.should match 'These changes will be made'
                mail.should match 'Validation: '
                mail.should match @sender.name
              end
            end # 'but trying to change own record'
          end # sender is not a moderator
        end # incoming email is not validated

      end #a single member matches request
        
      context 'no member matches request' do
        before(:each) {Member.should_receive(:parse_update_command).and_return(nil)}

        it 'does not update record' do
          target.should_not_receive(:update_attributes)
          post :create, @params
        end

        it 'sends error email' do
          lambda{post :create, @params}.should change(mail_queue, :length).by(1)
          mail_destination.should == [@params['from']]
          mail.should match 'not found'
          mail.should match 'xxxxx vvvvv'  # The mock updates string
        end
      end #a single member matches request
        
      context 'more than one member matches request' do
        before(:each) {Member.should_receive(:parse_update_command).and_return(double_response)}

        it 'does not update record' do
          target.should_not_receive(:update_attributes)
          post :create, @params
        end

        it 'sends error email' do
          target.stub(:name => "Target 1 name")
          target_2.stub(:name => "Target 2 name")
          lambda{post :create, @params}.should change(mail_queue, :length).by(1)
          mail_destination.should == [@params['from']]
          mail.should match 'More than one person'
          mail.should match "Target 1 name"  # The mock updates string
          mail.should match "Target 2 name"  # The mock updates string
        end
      end #a single member matches request
    end # CHANGE command
    
#    describe 'location' do
#      it 'sends basic help info' do
#        Contact.stub_chain(:where, :member).and_return(@member)
#        @member.should_receive(:update_attributes).with('Cannes', instance_of(Date))
#        Notifier.should_receive(:send_generic).with(/Cannes/)
#        @params['plain'] = "location Cannes"
#        post :create, @params
#      end
#    end      
    

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
    
  end # handles these commands
   
  describe 'distributes email & sms to groups' do
    let(:group_1) { FactoryGirl.create(:group)}
    let(:group_2) { FactoryGirl.create(:group)}
    before(:each) do
      Message.stub(:create).and_return(@mock_message)
      test_sender(:member)
      @body = 'Test message'
      @params[:from] = 'test@test.com'
    end
    
    describe 'when sender is allowed' do
      
      it 'distributes email to groups when groups are found' do
        Message.should_receive(:create).with(hash_including({:send_sms=>false, :send_email=>true, 
                            :to_groups=>[group_1.id, group_2.id], :body=>@body}))
        @params['plain'] = "email #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
        post :create, @params
      end

      it 'distributes sms to groups when groups are found' do
        Message.should_receive(:create).with(hash_including({:send_sms=>true, :send_email=>false, 
                            :to_groups=>[group_1.id, group_2.id], :body=>@body}))
        @params['plain'] = "sms #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
        post :create, @params
      end

      it 'distributes sms & email to groups when groups are found' do
        Message.should_receive(:create).with(hash_including({:send_sms=>true, :send_email=>true, 
                            :to_groups=>[group_1.id, group_2.id], :body=>@body}))
        @params['plain'] = "d+email #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
        post :create, @params
      end

      it 'distributes to found groups when only some groups are found' do
        Message.should_receive(:create).with(hash_including({:send_sms=>false, :send_email=>true, 
                            :to_groups=>[group_1.id, group_2.id], :body=>@body}))
        @params['plain'] = "email badGroup #{group_1.abbrev} sadGroup #{group_2.abbrev}: #{@body}"
        post :create, @params
      end

      it 'creates no message when no groups are found' do
        Message.should_not_receive(:create)
        @params['plain'] = "email badGroup sadGroup: #{@body}"
        post :create, @params
      end
      
      it 'warns sender when SMS message is too long' do
        @params['plain'] = "sms #{group_1.abbrev} #{group_2.abbrev}: #{@body} #{'x' * 200}"
        Notifier.should_receive(:send_generic).with(@params[:from], /only the first 150/i).
          and_return(@mock_message)
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

        it 'warns that one group was not found' do
          Notifier.should_receive(:send_generic).with(@params[:from], 
            Regexp.new("was sent to groups #{group_1.group_name}.* badGroup was not found")).
            and_return(@mock_mail)
          @params['plain'] = "d badGroup #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
          post :create, @params
        end

        it 'warns that some groups were not found' do
          Notifier.should_receive(:send_generic).with(@params[:from], 
            Regexp.new("was sent to groups #{group_1.group_name}.* sadGroup were not found")).
            and_return(@mock_mail)
          @params['plain'] = "d badGroup sadGroup #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
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
    end # when sender is allowed
    
    describe 'when sender is forbidden' do
      before(:each) do
        test_sender(:limited)    
        @mod_group = FactoryGirl.create(:group, :group_name => 'Moderators')
      end
      
      it 'does not send email to groups' do
        Message.should_not_receive(:create).with(hash_including({:send_sms=>true, :send_email=>true, 
                            :to_groups=>[group_1.id, group_2.id], :body=>@body}))
        @params['plain'] = "email #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
        post :create, @params
      end

      it 'sends rejected email to moderators' do
        Message.should_receive(:create).with(hash_including({:send_sms=>false, :send_email=>true, 
                            :to_groups=>[@mod_group.id], :body=>"Rejected: #{@body}"}))
        @params['plain'] = "email #{group_1.abbrev} #{group_2.abbrev}: #{@body}"
        post :create, @params
      end
    end # when sender is forbidden
  end # Distributes email and sms to groups
  
  describe 'handles email responses to group messages' do
    
    describe '(unique email addr)' do
      before(:each) do
        responding_to = 25  # This is the id of the message being responded to
        @message = mock_model(Message, :deliver=>true, :process_response => nil)
        Message.stub(:find_by_id).with(responding_to).and_return(@message)
        @member = test_sender(:member)
        @subject_with_tag = 'Re: Important ' + 
          message_id_tag(:id=>responding_to, :location => :subject, :action=>:generate)
        @user_reply = "I'm in Kafanchan"
        @body_with_tag = message_id_tag(:id=>responding_to, :location => :body, :action=>:confirm_tag) +
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

      it 'responds w error msg to sender when msg_id is not found' do
        @body_with_tag = message_id_tag(:id=>999, :location => :body, :action=>:confirm_tag) +
          ' ' + @user_reply        
        @params[:plain] = @body_with_tag
        Message.stub(:find_by_id).and_return(nil)
        Message.should_receive(:find_by_id).with(999)
        @message.should_not_receive(:process_response)
        Notifier.should_receive(:send_generic).with(@params[:from], /error/i).
          and_return(@mock_message)
        post :create, @params
      end
      
    end # (unique email/phone)

    describe '(w duplicate email addr)' do

      it 'for all members having same email' do
        @message = Message.create(:send_email=>true, :to_groups => '1', :body => 'test')
        @member_1 = FactoryGirl.create(:member)  # handy if not most efficient way to make a member with a contact
        @member_1.stub :role => :member
        @member_2 = FactoryGirl.create(:member, :email_1 => @member_1.email_1) 
        Member.stub(:find_by_email => [@member_1, @member_2]) 
        @message.members << [@member_1, @member_2]  # Message was sent to these 2 members
        @params['plain'] = "!#{@message.id}"  # e.g. #24 if @message.id is 24
        @params['from'] = @member_1.primary_email
        post :create, @params
        sent_messages = @message.sent_messages
        sent_messages.should_not be_empty
        sent_messages.each {|sm| sm.msg_status.should == MessagesHelper::MsgResponseReceived}
      end
    end # (w duplicate email addr)
  end #    handles email responses to group messages   

  describe "validation string" do
    
    describe "is formed and checked correctly" do
    
      it 'returning nil when @from_address is empty' do
        create_validation_string('').should be_nil
      end

      it 'accepting its own generated validation' do
        v = create_validation_string('user@something.com')
        body = "All kinds of\n\nheaders and other stuff \n\n #{v} and even more garbage"
        controller.check_validation_string(body).should be_true
      end
      
      it 'rejecting a corrupted validation' do
        controller.check_validation_string('no validation string').should be_nil
      end
      
      it 'rejecting validition with wrong email' do
        v = create_validation_string('user@something.com')
        # Make it appear that the email is from someone_else
        controller.instance_variable_set(:@from_address, 'someone_else@something.com')
        controller.check_validation_string(v).should be_false
      end
      
      it 'rejecting out of date validation' do
        v = create_validation_string('user@something.com')
        Timecop.travel(Date.today + 10.days)
        result = controller.check_validation_string(v)
        Timecop.return  # We don't really want to error-out of test before returning to real time
        result.should be_false
      end
    end 

    describe 'encryption and decryption' do
      it 'encrypts and decrypts text correctly' do
        text = 'The farmer in the dell'
        vstring = controller.encrypt(text)
        vstring.should_not match 'farmer'
        controller.decrypt("Validation: #{vstring}******").should eq text
      end

      it 'check returns nil when validation string not found' do
        controller.decrypt('nothing here folks').should be_nil
      end

      it 'check returns nil when input string is empty' do
        controller.decrypt('').should be_nil
      end

      it 'check returns nil when validation string corrupted' do
        text = 'The farmer in the dell'
        bogus_vstring = "Validation: abcdefg\nshouldbeencryptedstuff\n********"
        controller.decrypt(bogus_vstring).should be_nil
      end
    end # encryption & decryption
  end #  validation_string(text)
end
