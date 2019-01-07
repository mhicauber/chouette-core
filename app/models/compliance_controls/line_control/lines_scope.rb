module LineControl
  class LinesScope < ComplianceControl

    def self.default_code; "3-Line-2" end

    def prerequisite; I18n.t("compliance_controls.#{self.class.name.underscore}.prerequisite") end
  end
end
