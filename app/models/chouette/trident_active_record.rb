module Chouette
  class TridentActiveRecord < Chouette::ActiveRecord

    self.abstract_class = true

    def self.current_referential
      Referential.where(:slug => Apartment::Tenant.current).first!
    end

    def referential
      @referential ||= self.class.current_referential
    end

    def workgroup
      referential&.workgroup
    end

    def hub_restricted?
      referential.data_format == "hub"
    end

    def prefix
      referential.prefix
    end

  end
end
