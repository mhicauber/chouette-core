class ComplianceControlBlocksController < ChouetteController
  include PolicyChecker
  defaults resource_class: ComplianceControlBlock
  belongs_to :compliance_control_set
  actions :all, except: %i[show index]
  before_action :load_block_kind, only: %i[new edit]

  private

  def compliance_control_block_params
    params.require(:compliance_control_block).permit(:block_kind, :transport_mode, :transport_submode, :country, :min_stop_areas_in_country)
  end

  protected

  alias_method :compliance_control_set, :parent
  helper_method :compliance_control_set

  def load_block_kind
    @block_kinds = %w[transport_mode]
    @block_kinds << :stop_areas_in_countries if has_feature?(:core_control_blocks)
  end

end
