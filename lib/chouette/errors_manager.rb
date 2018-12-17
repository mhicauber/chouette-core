module Chouette
  class ErrorsManager
    class << self
      def handle_error(e, message=nil)
        message ||= 'An error occured'
        Rails.logger.error "#{message}: #{e.message} #{e.backtrace.join("\n")}"
      end

      def log_error(message)
        Rails.logger.error message
      end
    end
  end
end
