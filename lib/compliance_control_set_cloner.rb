class ComplianceControlSetCloner

  # Naming Convention: As we are in a domain with quite long names we
  #                    abbreviate compliance_control to cc and
  #                    compliance_check to cck iff used as prefixes.

  attr_reader :organisation_id, :source_set_id

  def copy source_set_id, organisation_id
    @source_set_id = source_set_id
    @organisation_id = organisation_id
    copy_set
  end


  private

  # Workers
  # -------

  # Copy Set:
  def copy_set
    # Force lazy creation of target_set, just in case source_set is _empty_.
    target_set
    copy_controls
    copy_blocks
  end

  # Copy Blocks:
  def copy_block source_block
    target_set.compliance_control_blocks.create(
      name: name_of_copy(:compliance_control_blocks, source_block.name),
      condition_attributes: source_block.condition_attributes).tap do | target_block |
        relink_checks_to_block source_block, target_block
      end
  end
  def copy_blocks
    source_set.compliance_control_blocks.order(:id).each(&method(:copy_block))
  end
  def relink_checks_to_block source_block, target_block
    source_block
      .compliance_controls
      .order(:id)
      .each do | source_control |
        control_id_map[source_control.id]
          .update(compliance_control_block_id: target_block.id)
      end
  end

  # Copy Controls:
  def copy_controls
    source_set.compliance_controls.order(:id).each(&method(:copy_control))
  end
  def copy_control(compliance_control)
    copied_attrs = [:code, :comment, :control_attributes, :criticity, :name, :origin_code, :type, :iev_enabled_check]
    target_set.compliance_controls.create(
      compliance_control.slice(*copied_attrs)
    ).tap do | control |
      control_id_map.update compliance_control.id => control
    end
  end

  def name_of_copy resource, name
    [I18n.t("#{resource}.clone.prefix"), name].join(' ')
  end

  # Lazy Values
  # -----------
  def organisation
    @__organisation__ ||= Organisation.find(organisation_id)
  end
  def source_set
    @__source_set__ ||= ComplianceControlSet.find(source_set_id)
  end
  def target_set
    @__target_set__ ||= ComplianceControlSet.create!(
      organisation: organisation,
      name: name_of_copy(:compliance_control_sets, source_set.name)
    )
  end
  def control_id_map
    # Map: compliance_control_id -> compliance_control (origin_id -> copied object)
    @__control_id_to_check__ ||= Hash.new
  end
  def referential
    @__referential__ ||= Referential.find(referential_id)
  end
end
