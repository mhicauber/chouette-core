module Chouette::DebugTools
  refine Merge.singleton_class do
    def status_sequence(scope=nil)
      scope ||= all
      scope.order("created_at ASC").map{|m| m.successful? ? 'v' : 'x'}.join()
    end
  end
end
