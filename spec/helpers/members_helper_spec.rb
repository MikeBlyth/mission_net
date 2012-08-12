describe MembersHelper do
extend MembersHelper
  
  describe 'Filter private data' do

    before(:each) do
      @privacy_columns = [:phone_1, :phone_2, :email_1, :email_2]
    end

    it 'hides private data from unprivileged user' do
      @member = FactoryGirl.build_stubbed(:member, :phone_private => true, :email_private => true)
      test_sign_in(:member)
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member).should eq t(:private_data)
      end
    end

    it 'shows non-private data to unprivileged user' do
      @member = FactoryGirl.build_stubbed(:member, :phone_private => false, :email_private => false)
      test_sign_in(:member)
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member).should eq @member.send(column)
      end
    end

    it 'shows private data to privileged user' do
      @member = FactoryGirl.build_stubbed(:member, :phone_private => true, :email_private => true)
      test_sign_in(:moderator)
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member).should eq @member.send(column)
      end
    end

    it 'shows private data to owner-user' do
      @member = test_sign_in(:moderator)
      @member.phone_private = true
      @member.email_private = true
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member).should eq @member.send(column)
      end
    end
  end # Filter private data
end
