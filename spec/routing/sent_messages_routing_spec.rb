require "spec_helper"

describe SentMessagesController do
  describe "routing" do

    it "routes to #index" do
      get("/sent_messages").should route_to("sent_messages#index")
    end

    it "routes to #new" do
      get("/sent_messages/new").should route_to("sent_messages#new")
    end

    it "routes to #show" do
      get("/sent_messages/1").should route_to("sent_messages#show", :id => "1")
    end

    it "routes to #edit" do
      get("/sent_messages/1/edit").should route_to("sent_messages#edit", :id => "1")
    end

    it "routes to #create" do
      post("/sent_messages").should route_to("sent_messages#create")
    end

    it "routes to #update" do
      put("/sent_messages/1").should route_to("sent_messages#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/sent_messages/1").should route_to("sent_messages#destroy", :id => "1")
    end

  end
end
