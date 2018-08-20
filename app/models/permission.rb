class Permission

  def self.base
    all_destructive_permissions + %w{sessions.create workbenches.update}
  end

  def self.extended
    permissions = base

    %w{purchase_windows exports}.each do |resources|
      actions = %w{edit update create destroy}
      actions.each do |action|
        permissions << "#{resources}.#{action}"
      end
    end

    permissions << "calendars.share"
  end

  def self.referentials
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

  def self.full
    extended + referentials
  end
end
