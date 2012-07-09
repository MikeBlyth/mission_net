require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe SentMessagesController do

  # This should return the minimal set of attributes required to create a valid
  # SentMessage. As you add validations to SentMessage, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SentMessagesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    it "assigns all sent_messages as @sent_messages" do
      sent_message = SentMessage.create! valid_attributes
      get :index, {}, valid_session
      assigns(:sent_messages).should eq([sent_message])
    end
  end

  describe "GET show" do
    it "assigns the requested sent_message as @sent_message" do
      sent_message = SentMessage.create! valid_attributes
      get :show, {:id => sent_message.to_param}, valid_session
      assigns(:sent_message).should eq(sent_message)
    end
  end

  describe "GET new" do
    it "assigns a new sent_message as @sent_message" do
      get :new, {}, valid_session
      assigns(:sent_message).should be_a_new(SentMessage)
    end
  end

  describe "GET edit" do
    it "assigns the requested sent_message as @sent_message" do
      sent_message = SentMessage.create! valid_attributes
      get :edit, {:id => sent_message.to_param}, valid_session
      assigns(:sent_message).should eq(sent_message)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new SentMessage" do
        expect {
          post :create, {:sent_message => valid_attributes}, valid_session
        }.to change(SentMessage, :count).by(1)
      end

      it "assigns a newly created sent_message as @sent_message" do
        post :create, {:sent_message => valid_attributes}, valid_session
        assigns(:sent_message).should be_a(SentMessage)
        assigns(:sent_message).should be_persisted
      end

      it "redirects to the created sent_message" do
        post :create, {:sent_message => valid_attributes}, valid_session
        response.should redirect_to(SentMessage.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved sent_message as @sent_message" do
        # Trigger the behavior that occurs when invalid params are submitted
        SentMessage.any_instance.stub(:save).and_return(false)
        post :create, {:sent_message => {}}, valid_session
        assigns(:sent_message).should be_a_new(SentMessage)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        SentMessage.any_instance.stub(:save).and_return(false)
        post :create, {:sent_message => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested sent_message" do
        sent_message = SentMessage.create! valid_attributes
        # Assuming there are no other sent_messages in the database, this
        # specifies that the SentMessage created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        SentMessage.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, {:id => sent_message.to_param, :sent_message => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested sent_message as @sent_message" do
        sent_message = SentMessage.create! valid_attributes
        put :update, {:id => sent_message.to_param, :sent_message => valid_attributes}, valid_session
        assigns(:sent_message).should eq(sent_message)
      end

      it "redirects to the sent_message" do
        sent_message = SentMessage.create! valid_attributes
        put :update, {:id => sent_message.to_param, :sent_message => valid_attributes}, valid_session
        response.should redirect_to(sent_message)
      end
    end

    describe "with invalid params" do
      it "assigns the sent_message as @sent_message" do
        sent_message = SentMessage.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SentMessage.any_instance.stub(:save).and_return(false)
        put :update, {:id => sent_message.to_param, :sent_message => {}}, valid_session
        assigns(:sent_message).should eq(sent_message)
      end

      it "re-renders the 'edit' template" do
        sent_message = SentMessage.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        SentMessage.any_instance.stub(:save).and_return(false)
        put :update, {:id => sent_message.to_param, :sent_message => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested sent_message" do
      sent_message = SentMessage.create! valid_attributes
      expect {
        delete :destroy, {:id => sent_message.to_param}, valid_session
      }.to change(SentMessage, :count).by(-1)
    end

    it "redirects to the sent_messages list" do
      sent_message = SentMessage.create! valid_attributes
      delete :destroy, {:id => sent_message.to_param}, valid_session
      response.should redirect_to(sent_messages_url)
    end
  end

end
