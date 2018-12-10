module ObjectidSupport
  extend ActiveSupport::Concern

  included do
    before_validation :before_validation_objectid, unless: Proc.new {|model| model.read_attribute(:objectid)}
    after_commit :after_commit_objectid, on: :create, if: Proc.new {|model| model.read_attribute(:objectid).try(:include?, '__pending_id__')}
    validates_presence_of :objectid
    validates_uniqueness_of :objectid, skip_validation: Proc.new {|model| model.read_attribute(:objectid).nil?}

    scope :with_short_id, ->(q){
      return self.none unless self.exists?
      referential = self.last.referential
      self.all.merge referential.objectid_formatter.with_short_id(self, q)
    }

    ransacker :short_id do |parent|
      nil
    end

    ransacker :actual_short_id, args: [:parent, :ransacker_args] do |parent, referential|
      Arel.sql referential.objectid_formatter.short_id_sql_expr(self)
    end

    class << self
      def search_with_objectid args={}
        vanilla_search = self.search_without_objectid args
        base = vanilla_search.base

        if args.is_a? Hash
          args.each do |k, v|
            if k =~ /short_id/
              referential = self.last&.referential
              if referential
                condition = Ransack::Nodes::Condition.new(base.context).build({
                  'a' => {
                    '0' => {
                      'name' => 'actual_short_id',
                      'ransacker_args' => referential
                    }
                  },
                  'p' => 'cont',
                  'v' => { '0' => { 'value' => v } }
                })

                base.conditions << condition
                base.combinator = "or"
              end
            end
          end
        end

        vanilla_search.instance_variable_set "@base", base
        vanilla_search
      end
      alias_method_chain :search, :objectid

      def ransackable_scopes(auth_object = nil)
        [:with_short_id]
      end

      def reset_objectid_format_cache!
        @_objectid_format_cache = nil
      end

      def has_objectid_format? referential_class, referential_find
        @_objectid_format_cache ||= AF83::SmartCache.new
        cache_key = { referential_class.name => referential_find }
        @_objectid_format_cache.fetch cache_key do
          referential = referential_class.find_by referential_find
          referential.objectid_format.present?
        end
      end
    end

    def objectid_formatter
      Chouette::ObjectidFormatter.for_objectid_provider(*referential_identifier)
    end

    def referential_identifier
      %w[line_referential stop_area_referential].each do |name|
        if (r = self.class.reflections[name])
          return [r.klass, { id: send(r.foreign_key) }]
        end
      end
      [Referential, { slug: referential_slug }]
    end

    def before_validation_objectid
      objectid_formatter.before_validation self
    end

    def after_commit_objectid
      objectid_formatter.after_commit self
    end

    def get_objectid
      objectid_formatter.get_objectid read_attribute(:objectid) if self.class.has_objectid_format?(*referential_identifier) && read_attribute(:objectid)
    end

    def objectid
      get_objectid.try(:to_s)
    end

    def objectid_class
      get_objectid.try(:class)
    end

    def raw_objectid
      read_attribute(:objectid)
    end

  end
end
