class ReferentialCloningWorker
  include Sidekiq::Worker
  include Concerns::ImportantWorker
  extend Concerns::FailingSupport

  def perform(id)
    ReferentialCloning.find(id).clone_with_status!
  end
end
