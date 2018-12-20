module Chouette
  class ErrorsManager
    class << self
      def log message, error: nil
        message = "#{message}: #{error.message} \n*** BACKTRACE ***\n#{error.backtrace.join("\n")}\n*****************" if error.present?
        to_rails_log message
      end
      alias handle log

      def invalid_model(model, message: nil)
        message = [message, "#{model.class.name} is not valid"].compact.join(': ')
        to_rails_log "#{message}:\n#{model.errors.messages.pretty_inspect}"
      end

      def watch(message=nil, on_failure: nil, raise_error: false)
        begin
          yield
        rescue => e
          if e.is_a? ::ActiveRecord::RecordInvalid
            invalid_model e.record, message: message
          else
            message ||= 'An error occured'
            log message, error: e
          end
          on_failure&.call
          raise if raise_error
        end
      end

      def to_rails_log message
        Rails.logger.error message
      end
    end
  end
end
