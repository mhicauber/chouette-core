class ApplicationModel < ::ActiveRecord::Base
  include MetadataSupport
  include ManagedErrorsSupport

  self.abstract_class = true
end
