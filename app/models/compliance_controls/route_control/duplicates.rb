require_dependency 'compliance_controls/route_control/internal_base'

module RouteControl
  class Duplicates < ComplianceControl

    def self.default_code; "3-Route-4" end
  end
end
