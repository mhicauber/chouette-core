class CleanUpWorker
  include Sidekiq::Worker
  extend Concerns::FailingSupport

  def perform(id, original_state=nil)
    cleaner = CleanUp.find id
    cleaner.original_state = original_state
    cleaner.run if cleaner.may_run?
    Chouette::ErrorsManager.watch 'CleanUpWorker failed' do
      cleaner.referential.switch
      result = cleaner.clean
    end
  end
end
