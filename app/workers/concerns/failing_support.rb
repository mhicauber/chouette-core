module Concerns::FailingSupport
  def perform_async_or_fail(operation, *opts)
    args = [operation.id] + opts
    perform_async *args
  rescue
    block_given? ? yield : operation.failed!
  end
end