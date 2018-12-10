class ComplianceCheckSetWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker
  extend Concerns::FailingSupport

  def perform(check_set_id, only_internals=false)
    check_set = ComplianceCheckSet.find(check_set_id)
    check_set.perform only_internals
  end
end
