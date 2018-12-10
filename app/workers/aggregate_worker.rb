class AggregateWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker
  extend Concerns::FailingSupport

  def perform(id)
    Aggregate.find(id).aggregate!
  end
end
