class AggregatesController < ChouetteController
  include PolicyChecker

  defaults resource_class: Aggregate
  belongs_to :workgroup

  respond_to :html

  def show
    @aggregate = @aggregate.decorate(context: {workgroup: parent})
  end

  private

  def build_resource
    super.tap do |aggregate|
      aggregate.creator = current_user.name
      aggregate.referentials = parent.aggregatable_referentials
    end
  end

  def aggregate_params
    aggregate_params = params.require(:aggregate).permit(:referential_ids, :notification_target)
    aggregate_params[:referential_ids] = aggregate_params[:referential_ids].split(",")
    aggregate_params[:user_id] ||= current_user.id
    aggregate_params
  end
end
