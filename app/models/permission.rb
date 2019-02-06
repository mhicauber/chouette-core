class Permission
  class << self
    def full
      (extended + referentials + user_permissions).uniq
    end

    def workgroup_permissions
      destructive_permissions_for %w[workgroups]
    end

    private

    def all_resources
      %w[
        access_points
        aggregates
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
        publication_setups
        publication_apis
        publication_api_keys
      ]
    end

    def destructive_permissions_for(models)
      models.product( %w{create destroy update} ).map{ |model_action| model_action.join('.') }
    end

    def read_permissions_for(models)
      models.product( %w{create destroy update} ).map{ |model_action| model_action.join('.') }
    end

    def all_destructive_permissions
      destructive_permissions_for( all_resources )
    end

    def user_permissions
      destructive_permissions_for %w[users]
    end

    def base
      all_destructive_permissions + %w{sessions.create workbenches.update}
    end

    def extended
      permissions = base

      %w{purchase_windows exports}.each do |resources|
        actions = %w{edit update create destroy}
        actions.each do |action|
          permissions << "#{resources}.#{action}"
        end
      end

      permissions << "calendars.share"
      permissions << "merges.rollback"
      permissions << "aggregates.rollback"
      permissions << "api_keys.index"
    end

    def referentials
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
  end

  class Profile
    @profiles = HashWithIndifferentAccess.new

    DEFAULT_PROFILE = :custom

    class << self
      def profile(name, permissions)
        @profiles[name] = permissions.sort
      end

      def each &block
        all.each &block
      end

      def all
        @profiles.keys.map(&:to_sym)
      end

      def all_i18n(include_default=true)
        keys = @profiles.keys
        keys << DEFAULT_PROFILE if include_default
        keys.map {|p| ["permissions.profiles.#{p}.name".t, p.to_s]}
      end

      def permissions_for(profile_name)
        @profiles[profile_name]
      end

      def profile_for(permissions)
        return DEFAULT_PROFILE unless permissions

        sorted = permissions.sort

        each do |profile|
          return profile if permissions_for(profile) == sorted
        end

        DEFAULT_PROFILE
      end

      def update_users_permissions
        User.where.not(profile: DEFAULT_PROFILE).find_each do |user|
          user.update profile: user.profile
        end
      end

      def set_users_profiles
        User.where(profile: nil).find_each {|u| u.update profile: Permission::Profile.profile_for(u.permissions)}
      end
    end

    profile :admin, Permission.full
    profile :editor, Permission.full.grep_v(/^users/)
    profile :visitor, %w{sessions.create}
  end
end
