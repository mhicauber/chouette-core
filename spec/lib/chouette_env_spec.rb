RSpec.describe SmartEnv do
  let(:env){ {} }

  before(:each) do
    SmartEnv.reset!
    allow(ENV).to receive(:fetch){|key| env.stringify_keys[key]}
    allow(ENV).to receive(:has_key?){|key| env.stringify_keys.has_key?(key)}
  end

  context "when calling an unexpected key" do
    it "should log the key" do
      expect(Rails.logger).to receive(:warn).once
      SmartEnv[:unexpected]
    end
  end

  context "with a missing required value" do
    it "should raise an error" do
      SmartEnv.add_required :missing
      expect{ SmartEnv.check! }.to raise_error(SmartEnv::MissingKey)
    end
  end

  context "when updating a key" do
    it "should not raise an error" do
      SmartEnv.add_required :foo
      SmartEnv.set :foo, required: false
      expect{ SmartEnv.check! }.to_not raise_error
      expect(SmartEnv[:foo]).to eq nil
      SmartEnv.set :foo, default: "bar"
      expect(SmartEnv[:foo]).to eq "bar"
      SmartEnv.set :foo, boolean: false
      expect(SmartEnv[:foo]).to eq "bar"
      SmartEnv.set :foo, default: nil
      expect(SmartEnv[:foo]).to eq nil
    end
  end

  context "with a present required value" do
    let(:env){
      {
        "required_key" => true
      }
    }
    it "should raise an error" do
      SmartEnv.add_required :required_key
      expect{ SmartEnv.check! }.to_not raise_error
    end
  end

  context "with plain value" do
    let(:env){
      {
        "key": "azerty"
      }
    }
    it "should parse them accurately" do

      SmartEnv.add :key
      expect(SmartEnv[:key]).to eq "azerty"
      expect(SmartEnv["key"]).to eq "azerty"
      expect(SmartEnv.fetch(:key)).to eq "azerty"
      expect(SmartEnv.fetch("key")).to eq "azerty"
    end
  end

  context "with default value" do
    before(:each){
      SmartEnv.add :with_default, default: "DEFAULT"
    }

    context "when the value is missing" do
      it "should fallback" do
        expect(SmartEnv[:with_default]).to eq "DEFAULT"
        expect(SmartEnv.fetch(:foo, default: "DEFAULT")).to eq "DEFAULT"
        expect(SmartEnv.fetch(:foo){ "DEFAULT" }).to eq "DEFAULT"
      end
    end

    context "when the value is present" do
      let(:env){
        {
          with_default: "NOT DEFAULT"
        }
      }
      it "should fallback" do
        expect(SmartEnv[:with_default]).to eq "NOT DEFAULT"
      end
    end
  end

  context "with boolean values" do
    let(:env){
      {
        "bool_1": true,
        "bool_2": "true",
        "bool_3": "0",
        "bool_4": "1",
        "bool_5": 0,
        "bool_6": 1,
        "bool_7": "",
        "bool_8": "   ",
        "bool_9": "false",
        "bool_10": false,
        "bool_11": "False",
        "bool_12": "NO",
      }
    }
    let(:truthy){ %i(bool_1 bool_2 bool_4 bool_6) }
    it "should parse them accurately when pre-defined" do
      env.keys.each do |k|
        SmartEnv.add_boolean k
      end
      env.keys.each do |k|
        expect(SmartEnv[k]).to (truthy.include?(k) ? be_truthy : be_falsy), "#{k} was expected to #{(truthy.include?(k) ? "be truthy" : "be falsy")}"
      end
      SmartEnv.add_boolean :not_in_env
      expect(SmartEnv[:not_in_env]).to be_falsy
    end

    it "should parse them accurately when unexpected" do
      env.keys.each do |k|
        expect(SmartEnv.boolean(k)).to (truthy.include?(k) ? be_truthy : be_falsy), "#{k} was expected to #{(truthy.include?(k) ? "be truthy" : "be falsy")}"
      end
      expect(SmartEnv.boolean(:not_in_env)).to be_falsy
    end
  end
end
