class ComplianceCheckSetWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker
  extend Concerns::FailingSupport

  def perform(check_set_id, only_internals=false)
    ComplianceCheckSet.find(check_set_id).perform only_internals
  end
end
