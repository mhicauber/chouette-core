module TomTom
  class Cache < TomTom::Delegator

    @@default_ttl = 14.days
    mattr_reader :default_ttl

    def initialize(coster)
      super
      @ttl = default_ttl
    end

    def complete(way_cost)
      if attributes = cache.read(way_cost.cache_key)
        way_cost.distance, way_cost.time = attributes[:distance], attributes[:time]
        true
      else
        false
      end
    end

    def cache
      Rails.cache
    end

    def after_coster(way_cost)
      if way_cost.distance and way_cost.time
        cache.write way_cost.cache_key, { distance: way_cost.distance, time: way_cost.time }, expires_in: @ttl
      end
    end

  end
end
