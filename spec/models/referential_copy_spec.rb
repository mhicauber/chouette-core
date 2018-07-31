require "rails_helper"

RSpec.describe ReferentialCopy do

  # XXX THIS IS A BIG COPY/PASTA FROM MERGE SPEC
  # We'll rewrite this as soon as the test DSL is available

  let(:stop_area_referential){ create :stop_area_referential }
  let(:line_referential){ create :line_referential }
  let(:company){ create :company, line_referential: line_referential }
  let(:workbench){ create :workbench, line_referential: line_referential, stop_area_referential: stop_area_referential }
  let(:referential_metadata){ create(:referential_metadata, lines: line_referential.lines.limit(3)) }
  let(:referential){
    create :referential,
      workbench: workbench,
      organisation: workbench.organisation,
      metadatas: [referential_metadata]
  }

  let(:target){
    create :referential,
      workbench: workbench,
      organisation: workbench.organisation,
      metadatas: []
  }

  let(:referential_copy){ ReferentialCopy.new(source: referential, target: target)}

  before(:each) do
    4.times { create :line, line_referential: line_referential, company: company, network: nil }
    10.times { create :stop_area, stop_area_referential: stop_area_referential }
  end

  context "#lines" do
    it "should use referential lines" do
      lines = referential.lines.to_a
      expect(referential).to receive(:lines).and_call_original
      expect(referential_copy.send(:lines).to_a).to eq lines
    end
  end

  context "#copy_metadatas" do
    it "should copy metadatas" do
      expect{referential_copy.send :copy_metadatas}.to change{target.metadatas.count}.by 1
      target_metadata = target.metadatas.last
      expect(target_metadata.lines).to eq referential_metadata.lines
      expect(target_metadata.periodes).to eq referential_metadata.periodes
    end

    context "run twice" do
      it "should copy metadatas only once" do
        referential_copy.send :copy_metadatas
        expect{referential_copy.send :copy_metadatas}.to change{target.metadatas.count}.by 0
        target_metadata = target.metadatas.last
        expect(target_metadata.lines).to eq referential_metadata.lines
        expect(target_metadata.periodes).to eq referential_metadata.periodes
      end
    end

    context "with exisiting overlapping periodes" do
      it "should copy metadatas only once" do
        referential_copy.send :copy_metadatas
        expect{referential_copy.send :copy_metadatas}.to change{target.metadatas.count}.by 0
        target_metadata = target.metadatas.last
        expect(target_metadata.lines).to eq referential_metadata.lines
        expect(target_metadata.periodes).to eq referential_metadata.periodes
      end
    end
  end

  context "#copy_routes" do
    let!(:route){
      referential.switch do
        create(:route, line: line_referential.lines.first)
      end
    }
    before(:each) do
      expect(referential_copy).to receive(:lines).at_least(:once).and_return(line_referential.lines)
    end

    context "without stop_points" do
      before(:each){
        referential.switch do
          route.stop_points.destroy_all
        end
      }
      it "should copy the routes" do
        expect{ referential_copy.send(:copy_routes) }.to change{ target.switch{ Chouette::Route.count } }.by 1
        former_route = referential.switch{ Chouette::Route.last }
        new_route = target.switch{ Chouette::Route.last }
        expect(referential_copy.send(:clean_attributes_for_copy, former_route)).to eq referential_copy.send(:clean_attributes_for_copy, new_route)
      end

      context "when the route already exists" do
        before(:each) do
          referential_copy.send(:copy_routes)
        end
        it "should fail" do
          expect{ referential_copy.send(:copy_routes) }.to raise_error ReferentialCopy::SaveError
        end
      end
    end

    context "with stop_points" do
      it "should copy_the_stop_points" do
        stop_points_count = referential.switch { route.stop_points.count }
        expect(referential_copy).to receive(:copy_route_stop_point).exactly(stop_points_count).times.and_call_original
        expect{ referential_copy.send(:copy_routes) }.to change{ target.switch{ Chouette::StopPoint.count } }.by stop_points_count
        target.switch do
          new_route =  Chouette::Route.last
          expect(new_route.stop_points.count).to eq stop_points_count
        end
      end
    end
  end

end
