module Chouette
  module ObjectidFormatter
    class Base
      include ::ActiveRecord::Sanitization

      def with_short_id scope, q
        scope.where("#{short_id_sql_expr} LIKE '%#{self.class.send(:sanitize_sql_like, q&.downcase)}%'")
      end
    end
  end
end
