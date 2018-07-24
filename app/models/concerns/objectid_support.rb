module ObjectidSupport
  extend ActiveSupport::Concern

  included do
    before_validation :before_validation_objectid, unless: Proc.new {|model| model.read_attribute(:objectid)}
    after_commit :after_commit_objectid, on: :create, if: Proc.new {|model| model.read_attribute(:objectid).try(:include?, '__pending_id__')}
    validates_presence_of :objectid
    validates_uniqueness_of :objectid, skip_validation: Proc.new {|model| model.read_attribute(:objectid).nil?}

    scope :with_short_id, ->(q){
      referential = self.last.referential
      self.all.merge referential.objectid_formatter.with_short_id(self, q)
    }

    ransacker :short_id do |parent|
      parent.table[:objectid]
    end

    class << self
      def search_with_objectid args
        scope = self
        args ||= {}
        args.each do |k, v|
          scope = scope.with_short_id(v) if k =~ /short_id/
        end
        scope.search_without_objectid args
      end
      alias_method_chain :search, :objectid
    end

    def self.ransackable_scopes(auth_object = nil)
      [:with_short_id]
    end

    def objectid_formatter
      self.referential.objectid_formatter
    end

    def before_validation_objectid
      objectid_formatter.before_validation self
    end

    def after_commit_objectid
      objectid_formatter.after_commit self
    end

    def get_objectid
      objectid_formatter.get_objectid read_attribute(:objectid) if self.referential.objectid_format && read_attribute(:objectid)
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
