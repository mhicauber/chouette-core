module TomTom
  class Minimum < TomTom::Delegator

    def initialize(coster)
      super
      @distance_minimum = 500
    end

    def complete(way_cost)
      # The current version doesn't support meters ...
      distance = way_cost.departure.distance_to(way_cost.arrival, units: :kms) * 1000
      return false if distance > @distance_minimum

      way_cost.distance, way_cost.time = distance, 60

      true
    end

  end
end
