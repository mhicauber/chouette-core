class MergeWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker
  extend Concerns::FailingSupport

  def perform(id)
    Merge.find(id).merge!
  end
end
