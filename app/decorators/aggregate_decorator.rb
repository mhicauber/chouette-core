class AggregateDecorator < AF83::Decorator
  decorates Aggregate
  set_scope { context[:workgroup] }

  with_instance_decorator do |instance_decorator|
    instance_decorator.action_link(
      primary: :show,
      policy: :rollback
    ) do |l|
      l.content t('aggregates.actions.rollback')
      l.method  :put
      l.href do
        h.rollback_workgroup_aggregate_path(context[:workgroup],object)
      end
    end
  end
end
