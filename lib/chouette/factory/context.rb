module Chouette
  class Factory
    class Context
      include Chouette::Logger

      attr_accessor :instance, :instance_name, :attributes, :parent

      def initialize(model, parent = nil)
        @model, @parent = model, parent
        parent.children << self if parent
      end

      def with_instance(instance)
        clone = self.dup
        clone.instance = instance
        clone
      end

      def path
        @path ||=
          begin
            prefix = "#{parent.path} > " if parent
            "#{prefix}#{@model.name}"
          end
      end

      def to_s
        path
      end

      def logger_prefix
        to_s
      end

      def evaluate(&block)
        dsl.instance_eval &block
      end

      def dsl
        @dsl ||= DSL.new(self)
      end

      def attributes
        @attributes ||= {}
      end

      delegate :root?, to: :model

      def create_instance
        unless root?
          parent.around_models do
            self.instance = build_instance
            instance.save!
          end

          if instance_name
            named_instances[instance_name] = instance
          end
        end

        children.each(&:create_instance)
      end

      def build_instance
        model.build_instance self
      end

      def find_instance(instance_name)
        return named_instances[instance_name] if named_instances[instance_name].present?
        return instance if model.name == instance_name

        out = []
        children.each do |child|
          out << child.find_instance(instance_name)
        end
        out.compact!

        raise Chouette::Factory::MultipleUnnamedModels if out.size > 1

        out.first
      end

      def find_instances(name)
        instance_name = name.to_s.singularize.to_sym

        return [instance] if model.name == instance_name

        children.flat_map do |child|
          child.find_instances name
        end
      end

      attr_accessor :model

      def named_instances
        unless root?
          parent.named_instances
        else
          @named_instances ||= {}
        end
      end

      def children
        @children ||= []
      end

      def create(name)
        path = model.find(name)
        if path
          new_context = self
          path.each do |sub_model|
            new_context = Context.new(sub_model, new_context)
          end
          new_context
        end
      end

      def build_model(name)
        context = self

        loop do
          if model_context = context.create(name)
            return model_context.build_instance
          end

          if context.root?
            raise "Can't build model #{name} from #{self.inspect}"
          end
          context = context.parent
        end
      end

      def around_models(&block)
        if root?
          block.call
        else
          log "Around models"
          parent.around_models do
            local_models_proc = model.around_models
            if local_models_proc
              log "local_models_proc: #{local_models_proc.inspect} with #{instance.inspect}"
              local_models_proc.call instance, block
            else
              block.call
            end
          end
        end
      end

    end
  end
end
