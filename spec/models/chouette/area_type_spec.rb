require "rails_helper"

RSpec.describe Chouette::AreaType do

  describe "::ALL" do
    it "includes all supported types" do
      expect(Chouette::AreaType::ALL).to match_array( %i(zdep zdlp lda gdl deposit border service_area relief other) )
      expect(Chouette::AreaType::COMMERCIAL).to match_array( %i(zdep zdlp lda gdl) )
      expect(Chouette::AreaType::NON_COMMERCIAL).to match_array( %i( deposit border service_area relief other) )
    end
  end

  describe ".find" do
    it "returns nil if the given code is nil" do
      expect(Chouette::AreaType.find(nil)).to be_nil
    end

    it "returns nil if the given code is unknown" do
      expect(Chouette::AreaType.find('dummy')).to be_nil
    end

    it "returns an AreaType associated to the code" do
      expect(Chouette::AreaType.find('zdep').code).to eq :zdep
    end
  end

  describe ".options" do
    before do
      Chouette::AreaType.reset_caches!
    end

    it "returns an array with label and code for each type" do
      allow(Chouette::AreaType).to receive(:all).and_return(%i{zdep lda})

      expected_options = [
        [Chouette::AreaType.find('zdep').label, :zdep],
        [Chouette::AreaType.find('lda').label, :lda]
      ]
      expect(Chouette::AreaType.options).to eq(expected_options)
    end
  end

  describe ".commercial=" do
    before(:each) do
      Chouette::AreaType.commercial = Chouette::AreaType::COMMERCIAL
    end
    context "when all values belongs to Chouette::AreaType::COMMERCIAL" do
      it "should set @@commercial to 'values'" do
        values = %i(zdep lda)
        Chouette::AreaType.commercial = values
        expect(Chouette::AreaType.commercial).to match_array(values)
      end
    end

    context "when at least one value of the list doesn't belong to Chouette::AreaType::COMMERCIAL" do
      it "should not change the value of @@commercial" do
        values = %i(unknow dummy deposit lda)
        Chouette::AreaType.commercial = values
        expect(Chouette::AreaType.commercial).to match_array(Chouette::AreaType::COMMERCIAL)
      end
    end
  end

  describe ".non_commercial=" do
    before(:each) do
      Chouette::AreaType.non_commercial = Chouette::AreaType::NON_COMMERCIAL
    end
    
    context "when all values belongs to Chouette::AreaType::NON_COMMERCIAL" do
      it "should set @@non_commercial to 'values'" do
        values = %i(deposit border)
        Chouette::AreaType.non_commercial = values
        expect(Chouette::AreaType.non_commercial).to match_array(values)
      end
    end

    context "when at least one value of the list doesn't belong to Chouette::AreaType::NON_COMMERCIAL" do
      it "should not change the value of @@non_commercial" do
        values = %i(unknow dummy deposit lda)
        Chouette::AreaType.non_commercial = values
        expect(Chouette::AreaType.non_commercial).to match_array(Chouette::AreaType::NON_COMMERCIAL)
      end
    end
  end

end
