class RoutingConstraintZoneDecorator < AF83::Decorator
  decorates Chouette::RoutingConstraintZone

  set_scope { [context[:referential], context[:line]] }

  # Action links require:
  #   context: {
  #     referential: ,
  #     line:
  #   }

  create_action_link(
    if: ->() {
      h.policy(Chouette::RoutingConstraintZone).create? &&
        context[:referential].organisation == h.current_organisation
    }
  )

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link
    instance_decorator.edit_action_link

    instance_decorator.destroy_action_link do |l|
      l.data {{ confirm: h.t('routing_constraint_zones.actions.destroy_confirm') }}
    end
  end
end
