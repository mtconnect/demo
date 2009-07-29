require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe DevicesController do
  describe "route generation" do
    it "maps #index" do
      route_for(:controller => "devices", :action => "index").should == "/devices"
    end

    it "maps #new" do
      route_for(:controller => "devices", :action => "new").should == "/devices/new"
    end

    it "maps #show" do
      route_for(:controller => "devices", :action => "show", :id => "1").should == "/devices/1"
    end

    it "maps #edit" do
      route_for(:controller => "devices", :action => "edit", :id => "1").should == "/devices/1/edit"
    end

    it "maps #create" do
      route_for(:controller => "devices", :action => "create").should == {:path => "/devices", :method => :post}
    end

    it "maps #update" do
      route_for(:controller => "devices", :action => "update", :id => "1").should == {:path =>"/devices/1", :method => :put}
    end

    it "maps #destroy" do
      route_for(:controller => "devices", :action => "destroy", :id => "1").should == {:path =>"/devices/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "generates params for #index" do
      params_from(:get, "/devices").should == {:controller => "devices", :action => "index"}
    end

    it "generates params for #new" do
      params_from(:get, "/devices/new").should == {:controller => "devices", :action => "new"}
    end

    it "generates params for #create" do
      params_from(:post, "/devices").should == {:controller => "devices", :action => "create"}
    end

    it "generates params for #show" do
      params_from(:get, "/devices/1").should == {:controller => "devices", :action => "show", :id => "1"}
    end

    it "generates params for #edit" do
      params_from(:get, "/devices/1/edit").should == {:controller => "devices", :action => "edit", :id => "1"}
    end

    it "generates params for #update" do
      params_from(:put, "/devices/1").should == {:controller => "devices", :action => "update", :id => "1"}
    end

    it "generates params for #destroy" do
      params_from(:delete, "/devices/1").should == {:controller => "devices", :action => "destroy", :id => "1"}
    end
  end
end
