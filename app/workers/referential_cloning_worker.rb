class ReferentialCloningWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker
  extend Concerns::FailingSupport

  def perform(id)
    ref = ReferentialCloning.find(id)
    ref.clone_with_status!
  end
end
