require_dependency 'compliance_controls/journey_pattern_control/min_max_cost'

module JourneyPatternControl
  class MinMaxTimeCost < MinMaxCost
    def self.default_code; "3-JourneyPattern-5" end

    def self.attribute_to_check
      :time
    end
  end
end
