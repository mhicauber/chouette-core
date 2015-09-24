# -*- coding: utf-8 -*-
module NinoxeExtension::Hub
  module TimeTableRestrictions
    extend ActiveSupport::Concern

    included do
      include ObjectidRestrictions

      with_options if: :hub_restricted? do |tt|
        # HUB-44
        tt.validate :specific_objectid
        # HUB-45
        #tt.validates_format_of :comment, :with => %r{\A[\w ]{0,75}\z}
        tt.validates_length_of :comment, :maximum => 75, :allow_blank => true, :allow_nil => true
      end
    end
    def specific_objectid
      validate_specific_objectid( 6)
    end
  end
end

