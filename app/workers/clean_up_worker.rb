class CleanUpWorker
  include Sidekiq::Worker
  extend Concerns::FailingSupport

  def perform(id, original_state=nil)
    cleaner = CleanUp.find id
    cleaner.original_state = original_state
    cleaner.run if cleaner.may_run?
    begin
      cleaner.referential.switch
      result = cleaner.clean
      # cleaner.successful(result)
    rescue Exception => e
      Rails.logger.error "CleanUpWorker : #{e}"
      # cleaner.failed({error: e.message})
    end
  end
end
