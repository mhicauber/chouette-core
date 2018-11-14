module Chouette
  module ObjectidFormatter
    class StifCodifligne < Base

      def short_id_sql_expr(table_name = nil)
        objectid_ref = table_name ? "#{table_name}.objectid" : 'objectid'
        "lower(split_part(#{objectid_ref}, ':', 4))"
      end

      def before_validation(model)
        # unused method in this context
      end

      def after_commit(model)
        # unused method in this context
      end

      def get_objectid(definition)
        parts = definition.try(:split, ":")
        Chouette::Objectid::StifCodifligne.new(provider_id: parts[0], sync_id: parts[1], object_type: parts[2], local_id: parts[3])
      end
    end
  end
end
