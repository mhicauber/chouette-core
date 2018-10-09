class AggregateWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker

  def perform(id)
    Aggregate.find(id).aggregate!
  end
end
