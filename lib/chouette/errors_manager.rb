module Chouette
  class ErrorsManager
    class << self
      def handle_error(e, message: nil, context: nil, severity: :error)
        message ||= 'An error occured'

        to_rails_log "#{message}: #{e.message} #{e.backtrace.join("\n")}"
        Bugsnag.notify e do |report|
          report.context = context
          report.severity = severity
        end
      end

      def log_error(message, context: nil, severity: :error, exception: nil)
        to_rails_log message
        Bugsnag.notify exception || message do |report|
          report.context = context
          report.severity = severity
        end
      end

      def invalid_model(model, message: nil, context: nil, exception: nil, severity: :warning)
        message ||= "#{model.class.name} is not valid"
        to_rails_log "#{message}: #{model.errors.inspect}"
        Bugsnag.notify exception || :invalid_model do |report|
          report.add_tab :errors, model.errors.to_h
          report.context = context
          report.severity = severity
        end
      end

      def to_rails_log message
        Rails.logger.error message
      end
    end
  end
end
