require "rails_helper"

RSpec.describe ReferentialCopy do
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
      route = create :route, line: line_referential.lines.last
      journey_pattern = route.full_journey_pattern
      create :vehicle_journey, journey_pattern: journey_pattern
    end
  end

  context "#copy" do
    context "with no data" do
      it "should succeed" do
        referential_copy.copy
        expect(referential_copy.status).to eq :successful
        expect(referential_copy.last_error).to be_nil
      end
    end

    context "with data" do
      before(:each){
        referential.switch do
          create(:route, line: referential.lines.first)
        end
      }
      it "should succeed" do
        referential_copy.copy
        expect(referential_copy.status).to eq :successful
        expect(referential_copy.last_error).to be_nil
      end

      context "with an error" do
        before(:each){
          allow_any_instance_of(Chouette::Route).to receive(:save!).and_raise("boom")
        }

        it "should fail" do
          referential_copy.copy
          expect(referential_copy.status).to eq :failed
          expect(referential_copy.last_error).to match /boom/
          expect(referential_copy.last_error).to match /Chouette::Route/
        end
      end
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

    context "with existing overlapping periodes" do
      it "should create a new metadata nonetheless" do
        referential
        target
        overlapping_metadata = target.metadatas.last
        period = referential_metadata.periodes.last
        overlapping_metadata.periodes = [(period.max-1.day..period.max+1.day)]
        overlapping_metadata.line_ids = referential_metadata.line_ids
        overlapping_metadata.save!
        expect{referential_copy.send :copy_metadatas}.to change{target.metadatas.count}.by 1
        target_metadata = target.metadatas.reload.last
        expect(target_metadata.lines).to eq referential_metadata.lines
        expect(target_metadata.periodes).to eq [period]
      end
    end
  end

  context "#copy_footnotes" do
    let!(:footnote){
      referential.switch do
        create(:footnote, line: line_referential.lines.first)
      end
    }

    it "should copy the footnotes" do
      referential.switch
      expect{ referential_copy.send(:copy_footnotes, footnote.line.reload) }.to change{ target.switch{ Chouette::Footnote.count } }.by 1
      new_footnote = target.switch{ Chouette::Footnote.last }
      expect(referential_copy.send(:clean_attributes_for_copy, footnote)).to eq referential_copy.send(:clean_attributes_for_copy, new_footnote)
    end
  end

  context "#copy_time_tables" do
    let!(:time_table){
      referential.switch do
        create(:time_table)
      end
    }

    it "should copy the time_tables" do
      referential.switch
      expect{ referential_copy.send(:copy_time_tables) }.to change{ target.switch{ Chouette::TimeTable.count } }.by 1
      new_timetable = target.switch{ Chouette::TimeTable.last }
      expect(referential_copy.send(:clean_attributes_for_copy, new_timetable)).to eq referential_copy.send(:clean_attributes_for_copy, time_table)
      expect(new_timetable.checksum).to eq time_table.checksum
    end
  end

  context "#copy_purchase_windows" do
    let!(:purchase_window){
      referential.switch do
        create(:purchase_window)
      end
    }

    it "should copy the purchase_windows" do
      referential.switch
      expect{ referential_copy.send(:copy_purchase_windows) }.to change{ target.switch{ Chouette::PurchaseWindow.count } }.by 1
      new_purchase_window = target.switch{ Chouette::PurchaseWindow.last }
      expect(referential_copy.send(:clean_attributes_for_copy, new_purchase_window)).to eq referential_copy.send(:clean_attributes_for_copy, purchase_window.reload)
      expect(new_purchase_window.checksum).to eq purchase_window.checksum
    end
  end

  context "#copy_routes" do
    let!(:route){
      referential.switch do
        create(:route, :with_opposite, line: line_referential.lines.first)
      end
    }

    before(:each){ referential.switch }

    context "with stop_points" do
      it "should copy the stop_points" do
        stop_points_count = referential.switch { route.stop_points.count }
        stop_areas = referential.switch { route.stop_points.map{|sp| sp.stop_area.objectid} }
        expect{ referential_copy.send(:copy_route, route) }.to change{ target.switch{ Chouette::StopPoint.count } }.by stop_points_count
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

        expect{ referential_copy.send(:copy_route, route) }.to change{ target.switch{ Chouette::JourneyPattern.count } }.by journey_patterns_count
        target.switch do
          new_route = Chouette::Route.last
          expect(new_route.journey_patterns.count).to eq journey_patterns_count
          new_route.journey_patterns.each do |jp|
            expect(jp.stop_points.map{|sp| sp.stop_area.objectid}).to eq stop_areas[jp.objectid]
          end
        end
      end
    end

    context "with vehicle_journeys" do
      before(:each) do
        referential.switch do
          timetable = create :time_table
          purchase_window = create :purchase_window
          journey_pattern = create :journey_pattern, route: route, stop_points: route.stop_points.sample(3)
          3.times { create :vehicle_journey, journey_pattern: journey_pattern, time_tables: [timetable], purchase_windows: [purchase_window] }
        end
      end

      it "should copy the vehicle_journeys" do
        referential_copy.send(:copy_time_tables)
        referential_copy.send(:copy_purchase_windows)
        expect{ referential_copy.send(:copy_route, route) }.to change{ target.switch{ Chouette::VehicleJourney.count } }.by 3

        target.switch do
          new_route = Chouette::Route.last
          expect(new_route.reload.vehicle_journeys.count).to eq 3
          expect(new_route.journey_patterns.last.vehicle_journeys.count).to eq 3
        end
      end

      it "should copy the vehicle_journey_at_stops" do
        stop_areas = {}
        checksums = {}
        time_tables = {}
        purchase_windows = {}

        referential.switch do
          route.vehicle_journeys.each do |vj|
            stop_areas[vj.objectid] = vj.stop_points.map{|sp| sp.stop_area.objectid}
            checksums[vj.objectid] = vj.checksum
            time_tables[vj.objectid] = vj.time_tables.map(&:objectid)
            purchase_windows[vj.objectid] = vj.purchase_windows.map(&:objectid)
          end
        end

        referential_copy.send(:copy_time_tables)
        referential_copy.send(:copy_purchase_windows)
        referential_copy.send(:copy_route, route)

        target.switch do
          new_route = Chouette::Route.last
          new_route.vehicle_journeys.each do |vj|
            expect(vj.stop_points.map{|sp| sp.stop_area.objectid}).to eq stop_areas[vj.objectid]
            expect(vj.checksum).to eq checksums[vj.objectid]
            expect(vj.time_tables.map(&:objectid)).to eq time_tables[vj.objectid]
            expect(vj.purchase_windows.map(&:objectid)).to eq purchase_windows[vj.objectid]
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
        expect{ referential_copy.send(:copy_route, route) }.to change{ target.switch{ Chouette::RoutingConstraintZone.count } }.by rcz_count
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
