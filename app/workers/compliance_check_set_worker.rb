class ComplianceCheckSetWorker
  include Sidekiq::Worker

  def perform(check_set_id)
    ComplianceCheckSet.find(check_set_id).perform
  end
end
