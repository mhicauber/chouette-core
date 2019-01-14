class PublicationApiDecorator < AF83::Decorator
  decorates PublicationApi

  set_scope { context[:workgroup] }

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link
    instance_decorator.edit_action_link
    instance_decorator.destroy_action_link
  end
end
