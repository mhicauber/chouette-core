class MergesController < ChouetteController
  include PolicyChecker

  defaults resource_class: Merge
  belongs_to :workbench

  respond_to :html

  def show
    @merge = @merge.decorate(context: {workbench: parent})
  end

  def available_referentials
    autocomplete_collection = parent.referentials.mergeable
    if params[:q].present?
      autocomplete_collection = autocomplete_collection.autocomplete(params[:q]).order(:name)
    else
      autocomplete_collection = autocomplete_collection.order('created_at desc')
    end

    render json: autocomplete_collection.limit(10)
  end

  def rollback
    authorize resource
    resource.rollback!
    redirect_to [:workbench, :output]
  end

  private

  def build_resource
    super.tap do |merge|
      merge.creator = current_user.name
    end
  end

  def merge_params
    merge_params = params.require(:merge).permit(:referential_ids, :notification_target)
    merge_params[:referential_ids] = merge_params[:referential_ids].split(",")
    merge_params[:user_id] ||= current_user.id
    merge_params
  end
end
