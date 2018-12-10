module Chouette
  module ObjectidFormatter
    class StifReflex < Base

      def short_id_sql_expr(model_class)
        "lower(split_part(#{table_name(model_class)}.objectid, ':', 4))"
      end

      def before_validation(model)
        # unused method in this context
      end

      def after_commit(model)
        # unused method in this context
      end

      def get_objectid(definition)
        parts = definition.try(:split, ":")
        Chouette::Objectid::StifReflex.new(country_code: parts[0], zip_code: parts[1], object_type: parts[2], local_id: parts[3], provider_id: parts[4])
      end
    end
  end
end
