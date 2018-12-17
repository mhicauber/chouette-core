module Concerns::FailingSupport
  def perform_async_or_fail(operation, *opts)
    args = [operation.id] + opts
    perform_async *args
  rescue => e
    # TODO #8018
    Rails.logger.error "Can't start worker: #{e.message} #{e.backtrace.join("\n")}"
    block_given? ? yield : operation.failed!
  end
end
