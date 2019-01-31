module ComplianceCheckSetsHelper
  def compliance_check_set_path(compliance_check_set)
    workbench_compliance_check_set_path(compliance_check_set.workbench, compliance_check_set)
  end

  def executed_compliance_check_set_path(compliance_check_set)
    executed_workbench_compliance_check_set_path(compliance_check_set.workbench, compliance_check_set)
  end

  def compliance_check_path(compliance_check)
    workbench_compliance_check_set_compliance_check_path(
      compliance_check.compliance_check_set.workbench,
      compliance_check.compliance_check_set,
      compliance_check)
  end

    # Import statuses helper
  def compliance_check_set_status(status)
    if %w[new running pending].include? status
      content_tag :span, '', class: "fa fa-clock-o"
    else
      cls =''
      cls = 'success' if status == 'successful'
      cls = 'warning' if status == 'warning'
      cls = 'danger' if %w[failed aborted canceled].include? status

      content_tag :span, '', class: "fa fa-circle text-#{cls}"
    end
  end

  def compliance_check_set_metadatas(check_set)
    metadata = {}
    if @compliance_check_set.referential.nil?
      metadata = metadata.update({ I18n.t("compliance_check_sets.show.metadatas.referential") => '' })
    else
      metadata = metadata.update({ I18n.t("compliance_check_sets.show.metadatas.referential") => link_to_if_i_can(@compliance_check_set.referential.name, referential_path(@compliance_check_set.referential), object: @compliance_check_set.referential) })
    end

    metadata = metadata.update({ I18n.t("compliance_check_sets.show.metadatas.referential_type") => 'Jeu de données' })
    metadata = metadata.update({ I18n.t("compliance_check_sets.show.metadatas.status") => operation_status(@compliance_check_set.status, verbose: true) })

    if @parent.is_a?( Workbench )
      metadata = metadata.update({ I18n.t("compliance_check_sets.show.metadatas.compliance_check_set_executed") => link_to_if_i_can(@compliance_check_set.name, [:executed, @parent, @compliance_check_set], object: @compliance_check_set) })
    else
      metadata = metadata.update({ Workbench.ts.capitalize => link_to_if_i_can(@compliance_check_set.workbench.organisation.name, @compliance_check_set.workbench, object:  @compliance_check_set.workbench) })
    end

    metadata = metadata.update({  I18n.t("compliance_check_sets.show.metadatas.compliance_control_owner") => @compliance_check_set.organisation.name,
                                  I18n.t("compliance_check_sets.show.metadatas.import") => '',
                                  ComplianceCheckSet.tmf(:context) => @compliance_check_set.context_i18n })
    metadata = metadata.update({ ComplianceCheckSet.tmf(:notification_target) => I18n.t("operation_support.notification_targets.#{@compliance_check_set.notification_target || 'none'}") })
    metadata
  end
end
