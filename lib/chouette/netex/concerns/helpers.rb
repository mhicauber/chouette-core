module Chouette::Netex::Concerns::Helpers
  def format_time(time)
    time.utc.strftime('%Y-%m-%dT%H:%M:%S.%1NZ')
  end

  def id_with_entity(entity_name, *models)
    source = models.first

    id = source.objectid.gsub(source.class.name.demodulize, entity_name)
    return id if models.size == 1

    ids = models.map {|m| m.objectid.split(':')[2]}
    id.gsub ids.first, ids.join('-')
  rescue
    "#{entity_name}-#{models.map(&:objectid).join('-')}"
  end

  def node_if_content name, &block
    built = @builder.send name, &block
    node = built.instance_variable_get("@node")
    node.remove if node.children.count.zero?
  end
end
