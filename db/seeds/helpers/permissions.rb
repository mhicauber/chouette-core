

module Seed

  def self.all_features
    %w{application_days_on_calendars change_locale consolidated_offers core_controls costs_in_journey_patterns create_opposite_routes detailed_calendars detailed_purchase_windows journey_length_in_vehicle_journeys long_distance_routes purchase_windows referential_vehicle_journeys route_stop_areas_all_types stop_area_localized_names stop_area_waiting_time vehicle_journeys_return_route}
  end

  def self.edit_permissions
    Stif::PermissionTranslator.translate(["boiv:edit-offer"])
  end

  def self.base_permissions
    permissions = edit_permissions

    %w{purchase_windows exports}.each do |resources|
      actions = %w{edit update create destroy}
      actions.each do |action|
        permissions << "#{resources}.#{action}"
      end
    end

    permissions << "calendars.share"
    permissions << "workbenches.update"
  end

  def self.referentials_permissions
    permissions = []
    %w{stop_areas stop_area_providers lines companies networks}.each do |resources|
      actions = %w{edit update create}
      actions << (%w{stop_areas lines}.include?(resources) ? "change_status" : "destroy")

      actions.each do |action|
        permissions << "#{resources}.#{action}"
      end
    end
    permissions
  end

  def self.all_permissions
    base_permissions + referentials_permissions
  end

end
