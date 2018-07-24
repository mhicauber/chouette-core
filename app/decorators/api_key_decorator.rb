class ApiKeyDecorator < AF83::Decorator
  decorates ApiKey

  set_scope { context[:workbench] }

  create_action_link do |l|
    l.content t('api_keys.actions.new')
  end

  with_instance_decorator do |instance_decorator|
    instance_decorator.edit_action_link
    instance_decorator.destroy_action_link
  end
end

