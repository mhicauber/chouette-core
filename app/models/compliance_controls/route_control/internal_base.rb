module RouteControl
  class InternalBase < InternalControl::Base
    def self.object_path compliance_check, route
      referential_line_route_path(route.referential, route.line, route)
    end

    def self.collection_type(_)
      :routes
    end
  end
end
