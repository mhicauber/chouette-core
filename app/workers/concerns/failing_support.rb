module Concerns::FailingSupport
  def perform_async_or_fail(operation, *opts)
    args = [operation.id] + opts
    perform_async *args
  rescue => e
    Chouette::ErrorsManager.handle_error e, message: 'Can\'t start worker'
    block_given? ? yield : operation.failed!
  end
end
