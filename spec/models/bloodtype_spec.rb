describe Bloodtype do
  include SimTestHelper


  describe "check before destroy:" do

    it "does destroy only if there are no existing linked records" do
      test_check_before_destroy(:bloodtype, :health_data)
    end

  end # check before destroy
      
end

