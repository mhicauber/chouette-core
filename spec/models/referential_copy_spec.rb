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
      metadatas: [create(:referential_metadata)]
  }

  let(:referential_copy){ ReferentialCopy.new(source: referential, target: target)}

  before(:each) do
    4.times { create :line, line_referential: line_referential, company: company, network: nil }
    10.times { create :stop_area, stop_area_referential: stop_area_referential }
    target.switch do
      create :route, line: line_referential.lines.last
    end
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
        referential
        target
        overlapping_metadata = target.metadatas.last
        period = referential_metadata.periodes.last
        overlapping_metadata.periodes = [(period.max-1.day..period.max+1.day)]
        overlapping_metadata.line_ids = referential_metadata.line_ids
        overlapping_metadata.save!
        expect{referential_copy.send :copy_metadatas}.to change{target.metadatas.count}.by 0
        target_metadata = target.metadatas.reload.last
        expect(target_metadata.lines).to eq referential_metadata.lines
        expect(target_metadata.periodes).to eq [(period.min..period.max+1.day)]
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
      it "should copy the stop_points" do
        stop_points_count = referential.switch { route.stop_points.count }
        stop_areas = referential.switch { route.stop_points.map{|sp| sp.stop_area.objectid} }
        expect{ referential_copy.send(:copy_routes) }.to change{ target.switch{ Chouette::StopPoint.count } }.by stop_points_count
        target.switch do
          new_route = Chouette::Route.last
          expect(new_route.stop_points.count).to eq stop_points_count
          expect(new_route.stop_points.map{|sp| sp.stop_area.objectid }).to eq stop_areas
        end
      end
    end

    context "with journey_patterns" do
      before(:each) do
        referential.switch do
          2.times do
            create :journey_pattern, route: route, stop_points: route.stop_points.sample(3)
          end
        end
      end
      it "should copy the journey_patterns" do
        journey_patterns_count = referential.switch { route.journey_patterns.count }

        stop_areas = {}
        referential.switch do
          route.journey_patterns.each do |jp|
            stop_areas[jp.objectid] = jp.stop_points.map{|sp| sp.stop_area.objectid}
          end
        end

        expect{ referential_copy.send(:copy_routes) }.to change{ target.switch{ Chouette::JourneyPattern.count } }.by journey_patterns_count
        target.switch do
          new_route = Chouette::Route.last
          expect(new_route.journey_patterns.count).to eq journey_patterns_count
          new_route.journey_patterns.each do |jp|
            expect(jp.stop_points.map{|sp| sp.stop_area.objectid}).to eq stop_areas[jp.objectid]
          end
        end
      end
    end

    context "with routing_constraint_zones" do
      before(:each) do
        referential.switch do
          2.times do
            create :routing_constraint_zone, route: route, stop_point_ids: route.stop_points.sample(route.stop_points.count - 1).map(&:id)
          end
        end
      end
      it "should copy the routing_constraint_zones" do
        rcz_count = referential.switch { route.reload; route.routing_constraint_zones.count }
        stop_areas = {}
        referential.switch do
          route.routing_constraint_zones.each do |rcz|
            stop_areas[rcz.objectid] = rcz.stop_points.map{|sp| sp.stop_area.objectid}
          end
        end
        expect{ referential_copy.send(:copy_routes) }.to change{ target.switch{ Chouette::RoutingConstraintZone.count } }.by rcz_count
        target.switch do
          new_route = Chouette::Route.last
          expect(new_route.routing_constraint_zones.count).to eq rcz_count
          new_route.routing_constraint_zones.each do |rcz|
            expect(rcz.stop_points.map{|sp| sp.stop_area.objectid}).to eq stop_areas[rcz.objectid]
          end
        end
      end
    end
  end

end
