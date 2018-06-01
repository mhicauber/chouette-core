class ComplianceControlDecorator < AF83::Decorator
  decorates ComplianceControl

  set_scope { object.compliance_control_set }

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link do |l|
      l.content t('compliance_control_sets.actions.show')
      l.href do
        h.compliance_control_set_compliance_control_path(
          object.compliance_control_set.id,
          object.id
        )
      end
    end

    instance_decorator.edit_action_link

    instance_decorator.destroy_action_link do |l|
      l.data {{ confirm: h.t('compliance_controls.actions.destroy_confirm') }}
    end
  end

  define_instance_class_method :predicate do
    object_class.predicate
  end

  define_instance_class_method :prerequisite do
    object_class.prerequisite
  end

  define_instance_class_method :dynamic_attributes do
    object_class.dynamic_attributes
  end
end
