require 'spec_helper'
require 'sim_test_helper'

describe ReportsController do
#    before(:each) do
##        @user = Factory(:user, :admin=>true)
##        test_sign_in(@user)
#      test_sign_in_fast
#    end
  describe 'Directory' do
    before(:each) do
      test_sign_in_fast
    end

    it 'by location -- uses directory_by_location template' do
      get :directory, :by => 'location'
      response.should render_template "directory_by_location"
    end

    it 'by name -- uses directory template' do
      get :directory, :by => 'family'
      response.should_not render_template "directory_by_location"
      response.should render_template "directory"
    end

    it 'PDF version -- ' do
      mock_dir = mock('Directory')
      DirectoryDoc.stub(:new => mock_dir)
      members =  [FactoryGirl.build_stubbed(:member)]
      Group.stub(:members_in_multiple_groups => members)
      @params = {:format => 'pdf', :report_sorted_by_location => true , 'record' => {'to_groups' => [1]}}
      mock_dir.should_receive(:to_pdf).with(members, nil, 
          hash_including(@params)).and_return 'PDF REPORT'
      get :directory, @params
      response.content_type.should eq "application/pdf"
    end
    
  end # Directory by location
end
