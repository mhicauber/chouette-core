module JourneyPatternControl
  class InternalBase < InternalControl::Base
    enumerize :criticity, in: %i(error), scope: true, default: :error

    def self.object_path(_, journey_pattern)
      referential_line_route_journey_patterns_collection_path(
        journey_pattern.referential,
        journey_pattern.route.line, journey_pattern.route
      )
    end

    def self.collection_type(_)
      :journey_patterns
    end
  end
end
