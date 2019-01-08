module PublicationsHelper
  def destination_metadatas destination
    metadatas = {}
    metadatas.update( Destination.tmf(:type) => destination.human_type )
    metadatas.update( Destination.tmf(:name) => destination.name )
    destination.options.each do |k, v|
      metadatas.update( translate_option_key(destination.class, k) => translate_option_value(destination.class, k, v) )
    end
    metadatas
  end
end
