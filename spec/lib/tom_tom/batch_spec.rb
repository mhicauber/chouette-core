RSpec.describe TomTom::Batch do
  let(:batch) { TomTom::Batch.new(nil) }

  describe "#batch" do
    it "should call get_sub_batch!" do
      expect(batch).to receive(:get_sub_batch).and_return(nil)
      batch.batch []
    end

    context "with more than SUB_BATCH_SIZE waycosts" do
      it "should call get_sub_batch! twice" do
        expect(batch).to receive(:get_sub_batch).twice.and_return(nil)
        batch.batch [{}]*51
      end
    end
  end

  describe "#extract_costs_to_way_costs" do
    it "puts distance & time costs in way_costs" do
      way_costs = [
        WayCost.new(
          departure: Geokit::LatLng.new(48.85086, 2.36143),
          arrival: Geokit::LatLng.new(47.91231, 1.87606)
        ),
        WayCost.new(
          departure: Geokit::LatLng.new(47.91231, 1.87606),
          arrival: Geokit::LatLng.new(52.50867, 13.42879)
        )
      ]

      expected_way_costs = way_costs.deep_dup
      expected_way_costs[0].distance = 117947
      expected_way_costs[0].time = 7969
      expected_way_costs[1].distance = 1114379
      expected_way_costs[1].time = 71010

      batch_response = JSON.parse(read_fixture('tom_tom_batch.json'))

      expect(
        batch.extract_costs_to_way_costs!(way_costs, batch_response)
      ).to match_array(expected_way_costs)
    end
  end

  describe "#convert_way_costs" do
    it "turns WayCost points into a collection of colon-separated strings" do
      way_costs = [
        WayCost.new(
          departure: Geokit::LatLng.new(2, 48),
          arrival: Geokit::LatLng.new(3, 46)
        ),
        WayCost.new(
          departure: Geokit::LatLng.new(-71, 42),
          arrival: Geokit::LatLng.new(-71.5, 42.9)
        )
      ]

      expect(
        batch.convert_way_costs(way_costs)
      ).to eq([
        '2,48:3,46',
        '-71,42:-71.5,42.9'
      ])
    end
  end
end
