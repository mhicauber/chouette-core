module Concerns::FailingSupport
  def perform_async_or_fail(**opts)
    perform_async *opts.values
  rescue
    block_given? ? yield : operation.failed!
  end
end