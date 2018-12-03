require 'rails_helper'

RSpec.describe Aggregate, type: :model do
  context "with another concurent aggregate" do
    before do
       Aggregate.create(workgroup: referential.workbench.workgroup, referentials: [referential, referential])
    end

    it "should not be valid" do
      aggregate = Aggregate.new(workgroup: referential.workbench.workgroup, referentials: [referential, referential])
      expect(aggregate).to_not be_valid
    end
  end

  it "should clean previous aggregates" do
    referential.workbench.workgroup.update(owner: referential.organisation)
    15.times do
      a = Aggregate.create!(workgroup: referential.workbench.workgroup, referentials: [referential, referential])
      a.update status: :successful
    end
    Aggregate.last.aggregate!
    expect(Aggregate.count).to eq 10
  end
end
