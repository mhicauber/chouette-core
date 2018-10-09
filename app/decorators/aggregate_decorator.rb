class AggregateDecorator < AF83::Decorator
  decorates Aggregate
  set_scope { context[:workgroup] }

end
