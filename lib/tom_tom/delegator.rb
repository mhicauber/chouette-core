module TomTom
  class Delegator

    attr_reader :coster

    def initialize(coster)
      @coster = coster
    end

    def evaluate(way_costs)
      unless way_costs.present?
        Rails.logger.info "#{self.class.name}: No waycost present."
        return []
      end

      Rails.logger.info "#{self.class.name}: #{way_costs.size} waycosts to be evaluated"

      local_costs = []
      pending_costs = []

      way_costs.each do |way_cost|
        if complete(way_cost)
          local_costs << way_cost
        else
          pending_costs << way_cost
        end
      end

      if pending_costs.present?
        pending_costs = (coster.evaluate(pending_costs) || [])
        pending_costs.each { |c| after_coster c }
      end

      Rails.logger.info "#{self.class.name}: #{local_costs.size} local, #{pending_costs.size} evaluated"
      local_costs + pending_costs
    end

    def complete(way_cost)
      false
    end

    def after_coster(way_cost); end

  end
end
