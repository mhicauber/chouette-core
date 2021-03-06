class WorkbenchOutputsController < ChouetteController
  respond_to :html, only: [:show]
  defaults resource_class: Workbench

  def show
    @workbench = current_organisation.workbenches.find params[:workbench_id]
    workbench_merges = @workbench.merges.order("created_at desc").paginate(page: params[:page], per_page: 10)
    @workbench_merges = decorate_merges(workbench_merges)
  end

  private

  def decorate_merges(merges)
    MergeDecorator.decorate(
      merges,
      context: { 
        workbench: @workbench
      }
    )
  end
end
