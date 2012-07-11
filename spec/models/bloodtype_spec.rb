# == Schema Information
#
# Table name: bloodtypes
#
#  id         :integer         not null, primary key
#  abo        :string(255)
#  rh         :string(255)
#  full       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#  comment    :string(255)
#

describe Bloodtype do
  include SimTestHelper


  describe "check before destroy:" do

    it "does destroy only if there are no existing linked records" do
      test_check_before_destroy(:bloodtype, :health_data)
    end

  end # check before destroy
      
end

