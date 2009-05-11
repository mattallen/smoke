require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe "YQL" do
  before :all do
    # Fake web does not yet support regex matched uris
    
    FakeWeb.register_uri("query.yahooapis.com/*", :response => File.join(SPEC_DIR, 'supports', 'search-web.yql'))
    
    Smoke.yql(:search) do
      select  :all
      from    "search.web"
      where   :query, "ruby"
      
      emit do
        rename(:url => :link)
      end
    end
  end
  
  it "should have been activated" do
    Smoke[:search].should(be_an_instance_of(Smoke::Source::YQL::YQL))
  end
  
  it "should be a list of things" do
    Smoke[:search].items.should be_an_instance_of(Array)
  end
  
  describe "after dispatch" do
    before do
      Smoke[:search].output
    end
    
    it "should hold the url used to query" do
      Smoke[:search].request.uri.should == "http://query.yahooapis.com/v1/public/yql?q=SELECT%20*%20FROM%20search.web%20WHERE%20query%20=%20'ruby'&format=json"
    end
    
    it "should have renamed url to link" do
      Smoke[:search].output.first.should have_key(:link)
      Smoke[:search].output.first.should_not have_key(:href)
    end

    it "should output a ruby object" do
      Smoke[:search].output.should be_an_instance_of(Array)
    end
  end
  
  describe "yql definitions" do
    describe "setting a yql definition" do
      it "should respond to use"
      it "should only accept a valid URI"
    end
    
    describe "dispatching with a yql definition set" do
      it "should set the definition within the query for your original request"
    end
  end
end