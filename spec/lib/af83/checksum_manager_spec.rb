RSpec.describe AF83::Decorator do
  context "AF83::ChecksumManager#current" do
    it "should return an AF83::ChecksumManager::Inline" do
      expect(AF83::ChecksumManager.current).to be_a(AF83::ChecksumManager::Inline)
    end
  end

  context "AF83::ChecksumManager#watch" do
    it "should delegate to the current manager" do
      object = create(:route)
      expect(AF83::ChecksumManager.current).to receive(:watch).with(object).once
      AF83::ChecksumManager.watch object
    end
  end

  context "#resolve_object" do
    it "should parse the params" do
      object = create(:route)
      expect(AF83::ChecksumManager::SerializedObject.new(object).object).to eq(object)
      expect(AF83::ChecksumManager::SerializedObject.new(object).need_save).to be_falsy
      expect(AF83::ChecksumManager::SerializedObject.new([object.class.name, object.id]).object).to eq(object)
      expect(AF83::ChecksumManager::SerializedObject.new([object.class.name, object.id]).need_save).to be_truthy
    end
  end
end
