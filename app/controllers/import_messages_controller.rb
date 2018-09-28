class ImportMessagesController < ChouetteController
  defaults resource_class: Import::Message, collection_name: 'import_messages', instance_name: 'import_message'
  respond_to :csv
  belongs_to :import, :parent_class => Import::Base do
    belongs_to :import_resource, :parent_class => Import::Resource
  end

  def index
    index! do |format|
      format.csv {
        send_data Import::MessageExport.new(:import_messages => @import_messages).to_csv(:col_sep => "\;", :quote_char=>'"', force_quotes: true) , :filename => "#{t('import_messages.import_errors')}_#{@import_resource.name.gsub('.xml', '')}_#{Time.now.strftime("%d-%m-%Y_%H-%M")}.csv"
      }
    end
  end

  protected
  def collection
    @import_messages ||= parent.messages
  end

  def parent
    scope = current_organisation.imports
    @import_resource ||= Import::Resource.joins(:import).merge(scope).find(params[:import_resource_id])
  end
end
