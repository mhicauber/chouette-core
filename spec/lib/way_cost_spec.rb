RSpec.describe WayCost do

  describe "#cache_key" do

    subject(:way_cost) { WayCost.new(departure: 'departure', arrival: 'arrival') }

    it "should be way_costs/departure-arrival" do
      expect(way_cost.cache_key).to eq("way_costs/departure-arrival")
    end

  end

  describe ".from" do

    def stop_area(name)
      double to_lat_lng: "position-#{name}", id: name
    end

    def stop_areas(*names)
      names.map { |name| stop_area name }
    end

    context "for A and B stop_areas" do

      let(:way_costs) { WayCost.from(stop_areas(:a, :b)) }

      it "returns one way cost A-B" do
        expect(way_costs).to eq([WayCost.new(departure: "position-a", arrival: "position-b", id: "a-b")])
      end

    end

    context "when a stop area has no position" do

      let(:stop_area_without_position) { double to_lat_lng: nil, id: "no position" }
      let(:way_costs) { WayCost.from( [stop_area(:a), stop_area_without_position, stop_area(:b)]) }

      it "ignores the stop area without position and returns a way cost A-B" do
        expect(way_costs).to eq([WayCost.new(departure: "position-a", arrival: "position-b", id: "a-b")])
      end

    end

    context "for A, B and C stop_areas" do

      let(:way_costs) { WayCost.from(stop_areas(:a,:b,:c)) }

      it "returns 3 way costs" do
        expect(way_costs.size).to eq(3)
      end

      it "returns a way cost A-B" do
        expect(way_costs).to include(WayCost.new(departure: "position-a", arrival: "position-b", id: "a-b"))
      end

      it "returns a way cost A-C" do
        expect(way_costs).to include(WayCost.new(departure: "position-a", arrival: "position-c", id: "a-c"))
      end

      it "returns a way cost B-C" do
        expect(way_costs).to include(WayCost.new(departure: "position-b", arrival: "position-c", id: "b-c"))
      end

    end

  end

end
