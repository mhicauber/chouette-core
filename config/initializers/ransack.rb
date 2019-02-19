Ransack.configure do |config|
  config.add_predicate 'between',
                       arel_predicate: 'between',
                       formatter: proc { |v| v.split(' to ') },
                       type: :string
end

module Arel
  module Predications
    def between other
      min = other.is_a?(Range) ? other.min : other[0]
      max = other.is_a?(Range) ? other.max : other[1]
      gteq(min).and(lt(max))
    end
  end
end

module Ransack
  module Constants
    module_function
    # replace % \ to \% \\
    def escape_wildcards(unescaped)
      case ActiveRecord::Base.connection.adapter_name
      when "Mysql2".freeze, "PostgreSQL".freeze, "PostGIS".freeze
        # Necessary for PostgreSQL and MySQL
        unescaped.to_s.gsub(/([\\|\%|_|.])/, '\\\\\\1')
      else
        unescaped
      end
    end
  end
end
