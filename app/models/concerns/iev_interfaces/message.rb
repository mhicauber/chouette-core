module IevInterfaces::Message
  extend ActiveSupport::Concern

  included do
    extend Enumerize
    enumerize :criticity, in: %i[info warning error]
    validates :criticity, presence: true

    %i(info warning error).each do |criticity|
      scope criticity, ->{ where(criticity: criticity) }
    end
  end
end
