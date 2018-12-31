module CustomFieldControl
  class Presence < InternalControl::Base
    required_features :core_controls

    store_accessor :control_attributes, :custom_field_code

    def self.default_code; "3-Generic-4" end

    def self.object_path compliance_check, object
      polymorphic_path case custom_field(compliance_check).resource_type
      when "Company"
        [object.line_referential, object]
      when "VehicleJourney"
        [object.referential, object.route.line, object.route, :vehicle_journeys_collection]
      when "JourneyPattern"
        [object.referential, object.route.line, object.route, :journey_patterns_collection]
      when "StopArea"
        [object.stop_area_referential, object]
      else
        [compliance_check.referential]
      end
    end

    def self.collection referential, compliance_check
      custom_field = custom_field(compliance_check)
      referential.send(custom_field.resource_type.tableize)
    end

    def self.lines_for compliance_check, model
      compliance_check.referential.lines
    end

    def self.compliance_test compliance_check, object
      object.custom_fields[compliance_check.control_attributes["custom_field_code"]]&.display_value.present?
    end

    def self.custom_message_attributes compliance_check, object
      super.update(field_name: custom_field(compliance_check).name)
    end

    def self.custom_field compliance_check
      CustomField.find_by code: compliance_check.control_attributes["custom_field_code"]
    end

    def self.label_attr(compliance_check)
      case custom_field(compliance_check).resource_type
      when "VehicleJourney"
        :published_journey_name
      else
        super
      end
    end
  end
end
