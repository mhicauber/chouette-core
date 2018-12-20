module Concerns::FailingSupport
  def perform_async_or_fail(operation, *opts)
    args = [operation.id] + opts
    perform_async *args
  rescue => e
    Chouette::ErrorsManager.log 'Can\'t start worker', error: e
    block_given? ? yield : operation.failed!
  end
end
