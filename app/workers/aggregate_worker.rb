class AggregateWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker
  extend Concerns::FailingSupport

  def perform(id)
    aggregate = Aggregate.find(id)
    aggregate.aggregate!
  end
end
