describe Referential, :type => :model do
  it "should create an Organisation with all features" do
    subscription = Subscription.new organisation_name: "organisation_test"

    Feature.all.each do |feature|
      expect(subscription.organisation.has_feature?(feature)).to be_truthy
    end
  end
end