module Chouette
  class ErrorsManager
    class << self
      def handle_error(e, message: nil)
        message ||= 'An error occured'
        to_rails_log "#{message}: #{e.message} #{e.backtrace.join("\n")}"
      end

      def log_error(message)
        to_rails_log message
      end

      def invalid_model(model, message: nil)
        message ||= "#{model.class.name} is not valid"
        to_rails_log "#{message}: #{model.errors.inspect}"
      end

      def to_rails_log message
        Rails.logger.error message
      end
    end
  end
end
