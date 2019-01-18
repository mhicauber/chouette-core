module RoutingConstraintZonesHelper
  def can_create_rcz?
    @line.routes.with_at_least_three_stop_points.length > 0
  end
end