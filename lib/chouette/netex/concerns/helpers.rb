module Chouette::Netex::Concerns::Helpers
  def format_time(time_or_date)
    time_or_date.to_time.utc.strftime('%Y-%m-%dT%H:%M:%S.%1NZ')
  end

  def format_time_only(time)
    time.strftime('%H:%M:%S')
  end

  def format_date(date)
    date.strftime('%Y-%m-%d')
  end

  def id_with_entity(entity_name, *models, suffix: nil)
    source = models.first

    id = source.objectid.gsub(/#{source.class.name.demodulize}/i, entity_name)
    return id if models.size == 1 && !suffix

    ids = models.map {|m| m.objectid.split(':')[2]}
    ids << suffix if suffix
    id.gsub ids.first, ids.join('-')
  rescue
    "#{entity_name}-#{models.map(&:objectid).push(suffix).compact.join('-')}"
  end

  def node_if_content name, &block
    built = @builder.send name, &block
    node = built.instance_variable_get("@node")
    node.remove if node.children.count.zero?
  end
end
