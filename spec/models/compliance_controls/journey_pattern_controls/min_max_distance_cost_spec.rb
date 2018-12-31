require 'rails_helper'

RSpec.describe JourneyPatternControl::MinMaxDistanceCost, :type => :model do
  let!(:line){ create :line }
  let!(:ref){ create :workbench_referential, metadatas: [create(:referential_metadata, lines: [line])] }
  let!(:route) {create :route, line: line}
  let!(:jp) { create :journey_pattern, route: route}
  let(:criticity){ "error" }
  let(:compliance_check_set){ create :compliance_check_set, referential: referential}
  let(:compliance_check){
    create :compliance_check,
      iev_enabled_check: false,
      compliance_control_name: "JourneyPatternControl::MinMaxDistanceCost",
      control_attributes: {
        min: 10,
        max: 100
      },
      compliance_check_set: compliance_check_set,
      criticity: criticity
  }

  let(:costs){
    {}
  }

  before(:each) do
    jp.update costs: costs
  end

  context "when the journey pattern costs are not defined" do
    it "should not pass" do
      expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
      resource = ComplianceCheckResource.last
      expect(resource.status).to eq "ERROR"
    end
  end

  context "when the journey pattern costs are fully defined inside the range" do
    let(:costs){
      out = {}
      jp.stop_areas.each_cons(2) do |a, b|
        out["#{a.id}-#{b.id}"] = { distance: 50, time: 100 }
      end
      out
    }
    it "should pass" do
      expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
      resource = ComplianceCheckResource.last
      expect(resource.status).to eq "OK"
    end
  end

  context "when the journey pattern costs are partially defined" do
    let(:costs){
      out = {}
      jp.stop_areas.each_cons(2) do |a, b|
        out["#{a.id}-#{b.id}"] = { distance: 50, time: 100 }
      end
      out.delete out.keys[1]
      out
    }
    it "should fail" do
      expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
      resource = ComplianceCheckResource.last
      expect(resource.status).to eq "ERROR"
    end
  end

  context "when the journey pattern costs are fully defined above the range" do
    let(:costs){
      out = {}
      jp.stop_areas.each_cons(2) do |a, b|
        out["#{a.id}-#{b.id}"] = { distance: 500, time: 100 }
      end
      out
    }
    it "should fail" do
      expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
      resource = ComplianceCheckResource.last
      expect(resource.status).to eq "ERROR"
    end
  end

  context "when the journey pattern costs are fully defined below the range" do
    let(:costs){
      out = {}
      jp.stop_areas.each_cons(2) do |a, b|
        out["#{a.id}-#{b.id}"] = { distance: 5, time: 100 }
      end
      out
    }
    it "should fail" do
      expect{compliance_check.process}.to change{ComplianceCheckResource.count}.by 1
      resource = ComplianceCheckResource.last
      expect(resource.status).to eq "ERROR"
    end
  end
end
