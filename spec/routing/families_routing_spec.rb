require "spec_helper"

describe FamiliesController do
  describe "routing" do

    it "routes to #index" do
      get("/families").should route_to("families#index")
    end

    it "routes to #new" do
      get("/families/new").should route_to("families#new")
    end

    it "routes to #show" do
      get("/families/1").should route_to("families#show", :id => "1")
    end

    it "routes to #edit" do
      get("/families/1/edit").should route_to("families#edit", :id => "1")
    end

    it "routes to #create" do
      post("/families").should route_to("families#create")
    end

    it "routes to #update" do
      put("/families/1").should route_to("families#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/families/1").should route_to("families#destroy", :id => "1")
    end

  end
end
