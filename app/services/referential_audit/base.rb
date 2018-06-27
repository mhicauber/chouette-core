class ReferentialAudit
  class Base
    attr_reader :status

    def self.inherited klass
      ReferentialAudit::Full.register klass
    end

    def initialize referential
      @referential = referential
    end

    def perform logger
      raise
    end

    def name
      self.class.name
    end
  end
end

require_dependency 'referential_audit/purchase_windows_checksums'
require_dependency 'referential_audit/vehicle_journey_initial_offset'
