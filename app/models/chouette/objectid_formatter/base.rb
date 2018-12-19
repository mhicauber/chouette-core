module Chouette
  module ObjectidFormatter
    class Base
      include ::ActiveRecord::Sanitization

      def with_short_id scope, q
        scope.where("#{short_id_sql_expr(scope)} LIKE '%#{self.class.send(:sanitize_sql_like, q&.downcase)}%'")
      end

      def table_name(model_class)
        model_class.table_name.split(".").last
      end
    end
  end
end
