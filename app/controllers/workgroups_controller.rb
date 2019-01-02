class WorkgroupsController < ChouetteController
  defaults resource_class: Workgroup

  include PolicyChecker

  def show
    redirect_to "/"
  end

  def edit_controls
    edit!
  end

  def update_controls
    update!
  end

  def workgroup_params
    params[:workgroup].permit(
      :sentinel_min_hole_size,
      :sentinel_delay,
      :nightly_aggregate_enabled, :nightly_aggregate_time,
      workbenches_attributes: [
        :id,
        :locked_referential_to_aggregate_id,
        compliance_control_set_ids: @workgroup.compliance_control_sets_by_workgroup.keys
      ],
      compliance_control_set_ids: Workgroup.workgroup_compliance_control_sets
    )
  end

  def resource
    @workgroup = current_organisation.workgroups.find params[:id]
  end
end
