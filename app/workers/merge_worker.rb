class MergeWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker
  extend Concerns::FailingSupport

  def perform(id)
    merge = Merge.find(id)
    merge.merge!
  end
end
