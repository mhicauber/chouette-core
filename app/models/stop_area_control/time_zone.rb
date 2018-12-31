module StopAreaControl
  class TimeZone < InternalControl::Base
    required_features :core_controls

    def self.default_code; "3-StopArea-1" end

    def self.object_path compliance_check, stop_area
      stop_area_referential_stop_area_path(stop_area.stop_area_referential, stop_area)
    end

    def self.collection referential, _
      Chouette::StopArea.where id: referential.stop_points.pluck(:stop_area_id)
    end

    # def self.lines_for compliance_check, model
    #   compliance_check.referential.lines
    # end

    def self.compliance_test compliance_check, stop_area
      false
      # !!stop_area.parent_id ? stop_area.time_zone.nil? : true
    end
  end
end
