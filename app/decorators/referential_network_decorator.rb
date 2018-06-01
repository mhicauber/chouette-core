class ReferentialNetworkDecorator < AF83::Decorator
  decorates Chouette::Network

  set_scope { context[:referential] }

  # Action links require:
  #   context: {
  #     referential: ,
  #   }

  create_action_link do |l|
    l.content t('networks.actions.new')
  end

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link

    instance_decorator.edit_action_link do |l|
      l.content t('networks.actions.edit')
    end

    instance_decorator.destroy_action_link do |l|
      l.data {{ confirm: h.t('networks.actions.destroy_confirm') }}
    end
  end
end
