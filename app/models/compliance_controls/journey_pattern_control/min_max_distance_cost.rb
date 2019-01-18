require_dependency 'compliance_controls/journey_pattern_control/min_max_cost'

module JourneyPatternControl
  class MinMaxDistanceCost < MinMaxCost
    enumerize :criticity, in: %i(warning error), scope: true, default: :warning
    
    def self.default_code; "3-JourneyPattern-4" end
  end
end
