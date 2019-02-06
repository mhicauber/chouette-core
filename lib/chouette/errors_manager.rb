module Chouette
  class ErrorsManager
    class << self
      def log message, error: nil, extra_infos: []
        message = "#{message}: #{error.message} \n*** BACKTRACE ***\n#{error.backtrace.grep(/#{Rails.root.to_s}*/).join("\n")}\n*****************" if error.present?
        message = "#{message}\n#{extra_infos.join("\n")}" if extra_infos.present?
        to_rails_log message
      end
      alias handle log

      def invalid_model(model, message: nil)
        message = [message, "#{model.class.name} is not valid"].compact.join(': ')
        to_rails_log "#{message}:\n#{model.errors.messages.pretty_inspect}"
      end

      def watch(description, raise_error: false, verbose: false, &block)
        raise 'missing block' unless block_given?

        if block.arity > 0
          proxy = BlockProxy.new(block)
          binding = block.binding

          action = Chouette::SecureAction.new description, verbose: verbose, shift_caller: true do
            proc = proxy.__run
            binding.receiver.instance_eval &proc
          end

          if block.arity > 1
            action.on_failure raise_error: raise_error do
              if proc = proxy.__on_failure
                binding.receiver.instance_eval &proc
              end
            end
          end
          action.call
        else
          action = SecureAction.new description, verbose: verbose, shift_caller: true, &block
          action.call
        end
      end

      def to_rails_log message
        Rails.logger.error message
      end
    end

    class BlockProxy
      attr_reader :__run
      attr_reader :__on_failure

      def initialize(block)
        action_name = block.parameters[0].last
        failure_name = block.parameters[1]&.last

        if ([action_name, failure_name] & %i[__run __on_failure]).present?
          raise "`__run` and `__on_failure` are protected keywords in this context"
        end

        define_singleton_method action_name do |&block|
          @__run = block
        end

        if failure_name
          define_singleton_method failure_name do |&block|
            @__on_failure = block
          end
        end
        instance_exec &block
      end
    end
  end
end
