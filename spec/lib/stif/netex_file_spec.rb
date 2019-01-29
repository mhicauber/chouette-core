require 'stif/netex_file'
RSpec.describe STIF::NetexFile do

  let( :zip_file ){ fixtures_path 'OFFRE_TRANSDEV_2017030112251.zip' }

  let(:frames) { described_class.new(zip_file).frames }

  it "should return a frame for each sub directory" do
    expect(frames.size).to eq(2)
  end

  def period(from, to)
    Range.new(Date.parse(from), Date.parse(to))
  end

  context "each frame" do
    it "should return the line identifiers defined in frame" do
      expect(frames.map(&:line_refs).map(&:sort)).to match_array([%w{C00108 C00109}]*2)
    end
    it "should return periods defined in frame calendars" do
      expect(frames.map(&:periods)).to match_array([[period("2017-04-01", "2017-12-31")], [period("2017-03-01","2017-03-31")]])
    end
  end

  context 'with a different namespace' do
    let( :zip_file ){ fixtures_path 'netex_file_different_namespace.zip' }

    context "each frame" do
      it "should return the line identifiers defined in frame" do
        expect(frames.map(&:line_refs).map(&:sort)).to match_array([%w{C00108 C00109}]*2)
      end
      it "should return periods defined in frame calendars" do
        expect(frames.map(&:periods)).to match_array([[period("2017-04-01", "2017-12-31")], [period("2017-03-01","2017-03-31")]])
      end
    end
  end

  context 'without namespace' do
    let( :zip_file ){ fixtures_path 'netex_file_no_namespace.zip' }

    context "each frame" do
      it "should return the line identifiers defined in frame" do
        expect(frames.map(&:line_refs).map(&:sort)).to match_array([%w{C00108 C00109}]*2)
      end
      it "should return periods defined in frame calendars" do
        expect(frames.map(&:periods)).to match_array([[period("2017-04-01", "2017-12-31")], [period("2017-03-01","2017-03-31")]])
      end
    end
  end
end
