class WorkgroupsController < ChouetteController
  defaults resource_class: Workgroup

  include PolicyChecker

  def show
    redirect_to "/"
  end

  def workgroup_params
    params[:workgroup].permit(workbenches_attributes: [:id, compliance_control_set_ids: @workgroup.compliance_control_sets_by_workgroup.keys])
  end

  def resource
    @workgroup = current_organisation.workgroups.find params[:id]
  end
end
