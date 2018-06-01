class PurchaseWindowDecorator < AF83::Decorator
  decorates Chouette::PurchaseWindow

  set_scope { context[:referential] }

  create_action_link do |l|
    l.content t('purchase_windows.actions.new')
  end

  with_instance_decorator do |instance_decorator|
    instance_decorator.show_action_link do |l|
      l.content t('purchase_windows.actions.show')
    end

    instance_decorator.edit_action_link

    instance_decorator.destroy_action_link do |l|
      l.data {{ confirm: h.t('purchase_windows.actions.destroy_confirm') }}
    end
  end

  define_instance_method :bounding_dates do
    unless object.date_ranges.empty?
      object.date_ranges.map(&:min).min..object.date_ranges.map(&:max).max
    end
  end

end
