module ObjectidFormatterSupport
  extend ActiveSupport::Concern

  included do
    extend Enumerize
    enumerize :objectid_format,
              in: %w[netex stif_netex stif_reflex stif_codifligne]
    validates_presence_of :objectid_format

    after_save do
      Chouette::ObjectidFormatter.reset_objectid_providers_cache!
    end

    def objectid_formatter
      objectid_formatter_class.new
    end

    def objectid_formatter_class
      "Chouette::ObjectidFormatter::#{read_attribute(:objectid_format).camelcase}".constantize if read_attribute(:objectid_format)
    end
  end
end
