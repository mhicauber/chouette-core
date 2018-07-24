class LineFootnotesController < ChouetteController
  include ReferentialSupport
  defaults resource_class: Chouette::Line, collection_name: 'lines', instance_name: 'line'
  belongs_to :referential

  before_action :authorize_resource, only: [:destroy, :edit, :show, :update]
  before_action :authorize_resource_class, only: [:create, :index, :new]

  def update
    update! do |success, failure|
      success.html { redirect_to referential_line_footnotes_path(@referential, @line) , notice: t('notice.footnotes.updated') }
      failure.html { render :edit }
    end
  end

  protected

  protected
  def authorize_resource
    authorize resource, "#{action_name}_footnote?".to_sym
  end

  def authorize_resource_class
    authorize resource_class, "#{action_name}_footnote?".to_sym
  end

  alias_method :line, :resource

  def resource
    @line ||= current_referential.lines.find params[:line_id]
  end

  private

  def line_params
    params.require(:line).permit(
      { footnotes_attributes: [ :code, :label, :_destroy, :id ] } )
  end
end
