RSpec.shared_examples_for 'it has default netex resource attributes' do |extra_params|
  it 'should have correct attributes' do
    Timecop.freeze '2000-01-01 12:00 UTC' do
      expect(node['version']).to eq 'any'
      expect(node['id']).to eq resource.objectid
      expect(node['created']).to eq '2000-01-01T12:00:00.0Z'
      expect(node['changed']).to eq '2000-01-01T12:00:00.0Z'
      (extra_params || {}).each do |k, v|
        expect(node[k.to_s]).to eq v
      end
    end
  end
end

RSpec.shared_examples_for 'it has children matching attributes' do |matching|
  matching.each do |tag, attribute|
    it "should have a #{tag} child matching #{attribute} attribute" do
      expect(node.css(tag).size).to eq 1
      expect(node.css(tag).first.text.presence).to eq attr_to_val(attribute)
    end
  end
end

RSpec.shared_examples_for 'it has no child' do |name|
  it "should not have a #{name} child" do
    expect(node.css(name)).to be_empty, "No #{name} tag should be found in:\n #{node.to_xml}"
  end
end

RSpec.shared_examples_for 'it has one child with value' do |tag, attr|
  it "should have a #{tag} child with correct value" do
    tag = "> #{tag}" unless tag =~ /^>/

    expect(node.css(tag).size).to eq 1
    expect(node.css(tag).first.text.presence).to eq attr_to_val(attr)
  end
end

RSpec.shared_examples_for 'it has one child with ref' do |tag, attr|
  it "should have a #{tag} child with correct ref" do
    tag = "> #{tag}" unless tag =~ /^>/

    expect(node.css(tag).size).to eq 1
    expect(node.css(tag).first[:ref]).to eq attr_to_val(attr)
  end
end

RSpec.shared_examples_for 'it outputs custom fields' do |tag, attr|
  context 'with custom fields' do
    before(:each) do
      resource_type = resource.class.name.demodulize
      create :custom_field, field_type: :string, code: :energy, name: :energy, resource_type: resource_type, workgroup: workgroup
      create :custom_field, field_type: :string, code: :energy2, name: :energy2, resource_type: resource_type, workgroup: workgroup
    end

    after(:each) do
      resource.class.reset_custom_fields
    end

    it 'should have custom_fields' do
      resource.custom_field_values = { energy: 'foo', foo: 'bar', energy2: nil }
      expect(node.css('> keyList').size) .to eq 1
      expect(node.css('> keyList KeyValue').size) .to eq 1
      keyvalue = node.css('> keyList KeyValue')[0]
      expect(keyvalue.css('Key')[0].text).to eq 'energy'
      expect(keyvalue.css('Value')[0].text).to eq 'foo'
    end
  end
end
