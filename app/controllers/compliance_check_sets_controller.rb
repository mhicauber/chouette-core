class ComplianceCheckSetsController < ChouetteController
  defaults resource_class: ComplianceCheckSet
  include RansackDateFilter
  before_action only: [:index] { set_date_time_params("created_at", DateTime) }
  respond_to :html

  belongs_to :workbench

  def index
    index! do |format|
      scope = self.ransack_period_range(scope: @compliance_check_sets.joins(:compliance_control_set), error_message: t('compliance_check_sets.filters.error_period_filter'), query: :where_created_at_between)
      scope = scope.order(sort_column + ' ' + sort_direction) if sort_column && sort_direction
      @q_for_form = scope.ransack(params[:q])
      format.html {
        @compliance_check_sets = ComplianceCheckSetDecorator.decorate(
          @q_for_form.result.paginate(page: params[:page], per_page: 30)
        )
      }
    end
  end

  def show
    show! do
      @compliance_check_set = @compliance_check_set.decorate
    end
  end

  def executed
    show! do |format|
      # But now nobody is aware anymore that `format.html` passes a parameter into the block
      format.html { executed_for_html }
    end
  end

  def sort_column
    ComplianceCheckSet.column_names.include?(params[:sort]) ? params[:sort] : 'lower(compliance_check_sets.name)'
  end

  def joins_with_associated_objects(collection)
    collection
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : 'asc'
  end

  private

  # Action Implementation
  # ---------------------

  def executed_for_html
    @q_checks_form        = @compliance_check_set.compliance_checks.ransack(params[:q])
    @compliance_check_set = @compliance_check_set.decorate
    compliance_checks = @q_checks_form.result
      .group_by(&:compliance_check_block)
    @direct_compliance_checks        = compliance_checks.delete nil
    @blocks_to_compliance_checks_map = compliance_checks
  end
end
