module Seed

  def self.all_features
    Feature.all
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
