module AF83::EnhancedDecorator
  module ClassMethods
    def action_link args={}
      args[:if] = @_condition if args[:if].nil?

      options, link_options = parse_options args

      link = AF83::Decorator::Link.new(link_options)
      yield link if block_given?
      raise AF83::Decorator::IncompleteLinkDefinition.new(link.errors) unless link.complete?

      weight = options[:weight] || 1
      @_action_links ||= []
      @_action_links[weight] ||= []
      @_action_links[weight] << link
    end

    def with_condition condition, &block
      @_condition = condition
      instance_eval &block
      @_condition = nil
    end

    def action_links action
      (@_action_links || []).flatten.compact.select{|l| l.for_action?(action)}
    end

    def parse_options args
      options = {}
      %i(weight primary secondary footer on action actions policy if groups group).each do |k|
        options[k] = args.delete(k) if args.has_key?(k)
      end
      link_options = args.dup

      actions = options.delete :actions
      actions ||= options.delete :on
      actions ||= [options.delete(:action)]
      actions = [actions] unless actions.is_a?(Array)
      link_options[:_actions] = actions.compact

      link_options[:_groups] = options.delete(:groups)
      link_options[:_groups] ||= {}
      if single_group = options.delete(:group)
        if(single_group.is_a?(Symbol) || single_group.is_a?(String))
          link_options[:_groups][single_group] = true
        else
          link_options[:_groups].update single_group
        end
      end
      link_options[:_groups][:primary] ||= options.delete :primary
      link_options[:_groups][:secondary] ||= options.delete :secondary
      link_options[:_groups][:footer] ||= options.delete :footer

      link_options[:_if] = options.delete(:if)
      link_options[:_policy] = options.delete(:policy)
      [options, link_options]
    end
  end

  def action_links action=:index, opts={}
    @action = action&.to_sym
    links = AF83::Decorator::ActionLinks.new links: self.class.action_links(action), context: self, action: action
    group = opts[:group]
    links = links.for_group opts[:group]
    links
  end

  def primary_links action=:index
    action_links(action, group: :primary)
  end

  def secondary_links action=:index
    action_links(action, group: :secondary)
  end

  def check_policy policy
    _object = policy.to_s == "create" ? object.klass : object
    method = "#{policy}?"
    h.policy(_object).send(method)
  end
end
