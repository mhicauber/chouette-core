class MergesController < ChouetteController
  include PolicyChecker

  defaults resource_class: Merge
  belongs_to :workbench

  respond_to :html

  before_action :set_mergeable_controllers, only: [:new]

  protected

  def begin_of_association_chain
    current_organisation
  end

  private

  def set_mergeable_controllers
    @mergeable_referentials ||= parent.referentials.mergeable
    Rails.logger.debug "Mergeables: #{@mergeable_referentials.inspect}"
  end

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
    params.require(:merge).permit(
      referentials: []
      # :name,
      # :file,
      # :type,
      # :referential_id
    )
  end
end
