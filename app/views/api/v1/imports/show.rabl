object @import

attributes :id, :name, :status
node :referential_ids do |i|
  i.children.collect(&:referential_id).compact
end
