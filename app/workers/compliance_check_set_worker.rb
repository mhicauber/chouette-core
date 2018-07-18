class ComplianceCheckSetWorker
  include Sidekiq::Worker
  include Concerns::LongRunningWorker

  def perform(check_set_id)
    ComplianceCheckSet.find(check_set_id).perform
  end
end
