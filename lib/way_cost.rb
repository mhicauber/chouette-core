class WayCost
  attr_reader :departure, :arrival, :id
  attr_accessor :distance, :time

  def initialize(
    departure:,
    arrival:,
    distance: nil,
    time: nil,
    id: nil
  )
    @departure = departure
    @arrival = arrival
    @distance = distance
    @time = time
    @id = id
  end

  def ==(other)
    other.is_a?(self.class) &&
      @departure == other.departure &&
      @arrival == other.arrival &&
      @distance == other.distance &&
      @time == other.time &&
      @id == other.id
  end

  def cache_key
    "way_costs/#{departure}-#{arrival}"
  end

  def self.from(stop_areas)
    way_costs = []

    # A, B, C returns A-B, A-C, B-C
    stop_areas.each_with_index do |departure, index|
      stop_areas[index+1..-1].each do |arrival|
        next unless departure.to_lat_lng and arrival.to_lat_lng

        way_costs << WayCost.new(
          departure: departure.to_lat_lng,
          arrival: arrival.to_lat_lng,
          id: "#{departure.id}-#{arrival.id}"
        )
      end
    end

    way_costs
  end

end
