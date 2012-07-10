require "spec_helper"

describe AppLogsController do
  describe "routing" do

    it "routes to #index" do
      get("/app_logs").should route_to("app_logs#index")
    end

    it "routes to #new" do
      get("/app_logs/new").should route_to("app_logs#new")
    end

    it "routes to #show" do
      get("/app_logs/1").should route_to("app_logs#show", :id => "1")
    end

    it "routes to #edit" do
      get("/app_logs/1/edit").should route_to("app_logs#edit", :id => "1")
    end

    it "routes to #create" do
      post("/app_logs").should route_to("app_logs#create")
    end

    it "routes to #update" do
      put("/app_logs/1").should route_to("app_logs#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/app_logs/1").should route_to("app_logs#destroy", :id => "1")
    end

  end
end
