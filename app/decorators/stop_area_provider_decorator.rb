class StopAreaProviderDecorator < AF83::Decorator
  decorates StopAreaProvider

  set_scope { context[:referential] }

  create_action_link
  
  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link
    instance_decorator.edit_action_link
    instance_decorator.destroy_action_link
  end
end
