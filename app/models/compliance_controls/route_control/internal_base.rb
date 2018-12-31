module RouteControl
  class InternalBase < InternalControl::Base
    def self.object_path compliance_check, route
      referential_line_route_path(route.referential, route.line, route)
    end

    def self.collection(lines_scope, compliance_check)
      compliance_check.referential.routes_in_lines(lines_scope)
    end

    def self.compliance_test compliance_check, route
      route.stop_points.commercial.all? {|sp| sp.for_boarding == "forbidden" && sp.for_alighting == "forbidden" }
    end
  end
end
