class WorkgroupDecorator < AF83::Decorator
  decorates Workgroup

  create_action_link do |l|
    l.content t('workgroups.actions.new')
  end

  with_instance_decorator do |instance_decorator|
    ### primary (and secondary) can be
    ### - a single action
    ### - an array of actions
    ### - a boolean

    instance_decorator.show_action_link
    instance_decorator.edit_action_link

    instance_decorator.action_link secondary: true, policy: :edit do |l|
      l.content  t('workgroups.actions.edit_control_sets')
      l.href     {  [:edit_controls, object] }
    end
    instance_decorator.action_link secondary: true, policy: :edit do |l|
      l.content  t('workgroups.actions.edit_aggregate')
      l.href     {  [:edit_aggregate, object] }
    end
    instance_decorator.action_link secondary: true, policy: :edit do |l|
      l.content  t('workgroups.actions.edit_hole_sentinel')
      l.href     {  [:edit_hole_sentinel, object] }
    end
  end
end
