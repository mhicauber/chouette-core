class MergesController < ChouetteController
  include PolicyChecker

  defaults resource_class: Merge
  belongs_to :workbench

  respond_to :html

  protected

  def begin_of_association_chain
    current_organisation
  end

  private

  def build_resource
    super.tap do |merge|
      merge.creator = current_user.name
    end
  end

  # def build_resource
  #   @import ||= WorkbenchImport.new(*resource_params) do |import|
  #     import.workbench = parent
  #     import.creator   = current_user.name
  #   end
  # end

  def merge_params
    merge_params = params.require(:merge).permit(:referential_ids)
    merge_params[:referential_ids] = merge_params[:referential_ids].split(",")
    merge_params
  end
end
