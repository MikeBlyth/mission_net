describe MembersHelper do
extend MembersHelper
  
  describe 'Filter private data' do

    before(:each) do
      @privacy_columns = [:phone_1, :phone_2, :email_1, :email_2]
    end

    it 'hides private data from unprivileged user' do
      @member = FactoryGirl.build_stubbed(:member, :phone_private => true, :email_private => true)
      def current_user; test_sign_in(:member); end
      @privacy_columns.each do |column|
        # Self is the controller, so we have e.g. within controller phone_1_column(@member,nil)
        self.send(column.to_s + '_column', @member, nil).should eq t(:private_data)
      end
    end

    it 'shows non-private data to unprivileged user' do
      @member = FactoryGirl.build_stubbed(:member, :phone_private => false, :email_private => false)
      def current_user; test_sign_in(:member); end
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member, nil).should_not eq t(:private_data)
      end
    end

    it 'shows private data to privileged user' do
      @member = FactoryGirl.build_stubbed(:member, :phone_private => true, :email_private => true)
      def current_user; test_sign_in(:moderator); end
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member, nil).should_not eq t(:private_data)
      end
    end

    it 'shows private data to owner-user' do
      @member = test_sign_in(:moderator)
      def current_user; @member; end
      @member.phone_private = true
      @member.email_private = true
      @privacy_columns.each do |column|
        self.send(column.to_s + '_column', @member, nil).should_not eq t(:private_data)
      end
    end
  end # Filter private data
end
