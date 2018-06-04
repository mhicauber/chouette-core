module Stif
  module PermissionTranslator extend self

    def translate(sso_extra_permissions, organisation=nil)
      permissions = sso_extra_permissions.sort
        .flat_map(&method(:extra_permission_translation))
      permissions += extra_organisation_permissions(organisation)
      permissions.uniq
    end

    private

    def all_destructive_permissions
      destructive_permissions_for( all_resources )
    end

    def all_resources
      %w[
        access_points
        connection_links
        calendars
        footnotes
        imports
        exports
        merges
        journey_patterns
        referentials
        routes
        routing_constraint_zones
        time_tables
        vehicle_journeys
        api_keys
        compliance_controls
        compliance_control_sets
        compliance_control_blocks
        compliance_check_sets
        workbenches
        workgroups
      ]
    end

    def destructive_permissions_for(models)
        models.product( %w{create destroy update} ).map{ |model_action| model_action.join('.') }
    end

    def extra_permission_translation extra_permission
      translation_table.fetch(extra_permission, [])
    end

    def translation_table
      {
        "boiv:read-offer" => %w{sessions.create},
        "boiv:edit-offer" => all_destructive_permissions + %w{sessions.create workbenches.update},
      }
    end

    def extra_organisation_permissions organisation
      if organisation&.name&.downcase == "stif"
        return %w{calendars.share stop_area_referentials.synchronize line_referentials.synchronize}
      end
      []
    end
  end
end
