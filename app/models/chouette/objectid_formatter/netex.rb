module Chouette
  module ObjectidFormatter
    class Netex < Base

      def short_id_sql_expr
        "lower(split_part(split_part(objectid, ':', 3), '-', 1))"
      end

      def before_validation(model)
        oid = Chouette::Objectid::Netex.new(local_id: SecureRandom.uuid, object_type: model.class.name.gsub('Chouette::',''))
        model.update(objectid: oid.to_s) if oid.valid?
      end

      def after_commit(model)
        # unused method in this context
      end

      def get_objectid(definition)
        parts = definition.try(:split, ":")
        Chouette::Objectid::Netex.new(provider_id: parts[0], object_type: parts[1], local_id: parts[2], creation_id: parts[3])
      end
    end
  end
end
