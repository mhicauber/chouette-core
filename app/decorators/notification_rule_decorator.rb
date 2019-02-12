class NotificationRuleDecorator < AF83::Decorator
  decorates NotificationRule
  set_scope { context[:workbench] }

  create_action_link
  
  with_instance_decorator do |instance_decorator|

    instance_decorator.show_action_link

    instance_decorator.edit_action_link

    instance_decorator.destroy_action_link do |l|
      l.content { h.destroy_link_content('stop_areas.actions.destroy') }
      l.data {{ confirm: h.t('stop_areas.actions.destroy_confirm') }}
    end
  end
end