describe Referential, type: :model do
  it "creates an Organisation with all features" do
    subscription = Subscription.new organisation_name: "organisation_test"
    expect(subscription.organisation.features).to match_array(Feature.all)
  end
end
