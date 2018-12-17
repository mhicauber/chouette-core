class ReferentialDestroyWorker
  include Sidekiq::Worker
  extend Concerns::FailingSupport

  def perform(id)
    ref = Referential.find id
    ref.destroy if ref
  end
end
