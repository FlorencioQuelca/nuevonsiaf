require "spec_helper"

RSpec.describe SegurosController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/seguros").to route_to("seguros#index")
    end

    it "routes to #new" do
      expect(:get => "/seguros/new").to route_to("seguros#new")
    end

    it "routes to #show" do
      expect(:get => "/seguros/1").to route_to("seguros#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/seguros/1/edit").to route_to("seguros#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/seguros").to route_to("seguros#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/seguros/1").to route_to("seguros#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/seguros/1").to route_to("seguros#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/seguros/1").to route_to("seguros#destroy", :id => "1")
    end

  end
end
