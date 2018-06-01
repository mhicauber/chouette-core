class ComplianceControlSetDecorator < AF83::Decorator
  decorates ComplianceControlSet

  create_action_link do |l|
    l.content t('compliance_control_sets.actions.new')
  end

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link

    instance_decorator.edit_action_link do |l|
      l.content t('compliance_control_sets.actions.edit')
    end

    instance_decorator.action_link policy: :clone, secondary: :show do |l|
      l.content t('actions.clone')
      l.href { h.clone_compliance_control_set_path(object.id) }
    end

    instance_decorator.destroy_action_link do |l|
      l.content { h.destroy_link_content }
      l.href { h.compliance_control_set_path(object.id) }
      l.data {{ confirm: h.t('compliance_control_sets.actions.destroy_confirm') }}
    end
  end
end
