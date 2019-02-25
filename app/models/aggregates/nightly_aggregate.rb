class NightlyAggregate < Aggregate
  enumerize :notification_target, in: %w[none workgroup], default: :none
  
   def self.notification_target_options
    notification_target.values.map { |k| [k && "operation_support.notification_targets.#{k}".t, k] }
  end
end