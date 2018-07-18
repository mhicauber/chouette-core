class AutocompleteLinesController < ChouetteController
  include ReferentialSupport

  respond_to :json, only: :index

  protected

  def collection
    return [] if !params[:q]

    @lines = referential.line_referential.lines
    @lines = @lines.where("id IN (#{@lines.by_name(params[:q]).select(:id).to_sql}) OR id IN (#{@lines.search(number_or_company_name_cont: params[:q]).result.select(:id).to_sql})")
    @lines.paginate(page: params[:page])
  end
end
