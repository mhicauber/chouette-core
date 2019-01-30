require "rails_helper"

RSpec.describe Import::Workbench do

  let(:referential) do
    create :referential do |referential|
      referential.line_referential.objectid_format = "netex"
      referential.stop_area_referential.objectid_format = "netex"
    end
  end

  let(:new_referential){ create :referential }

  let(:workbench) do
    create :workbench do |workbench|
      workbench.line_referential.objectid_format = "netex"
      workbench.stop_area_referential.objectid_format = "netex"
    end
  end

  let(:options){
    {}
  }

  let(:import) {
    Import::Workbench.create workbench: workbench, name: "test", creator: "Albator", file: open_fixture("google-sample-feed.zip"), options: options
  }

  context '#file_type' do
    let(:filename) { 'google-sample-feed.zip' }
    let(:import) {
      Import::Workbench.new workbench: workbench, name: "test", creator: "Albator", file: open_fixture(filename), options: options
    }
    context 'with a GTFS file' do
      it 'should return :gtfs' do
        expect(import.file_type).to eq :gtfs
      end
    end

    context 'with a NETEX file' do
      let(:filename) { 'OFFRE_TRANSDEV_2017030112251.zip' }
      it 'should return :netex' do
        expect(import.file_type).to eq :netex
      end
    end

    context 'with a Neptune file' do
      let(:filename) { 'fake_neptune.zip' }
      it 'should return :neptune' do
        expect(import.file_type).to eq :neptune
      end
    end

    context 'with a malformed file' do
      let(:filename) { 'malformed_import_file.zip' }
      it 'should return nil' do
        expect(import.file_type).to be_nil
      end
    end
  end


  context "#done!" do
    it "should do nothing" do
      expect{import.done!}.to change{Merge.count}.by 0
    end

    context "when 'automatic_merge' is set'" do
      let(:options){
        {
          automatic_merge: "true"
        }
      }
      it "should do nothing" do
        expect{import.done!}.to change{Merge.count}.by 0
      end
    end

    context "when successful" do
      before(:each){ import.update status: :successful }

      it "should do nothing" do
        expect{import.done!}.to change{Merge.count}.by 0
      end

      context "when 'automatic_merge' is set'" do
        let(:options){
          {
            automatic_merge: "true"
          }
        }
        it "should create a Merge" do
          import.resources.create referential: new_referential
          expect{import.done!}.to change{Merge.count}.by 1
          merge = Merge.last
          expect(merge.creator).to eq import.creator
          expect(merge.workbench).to eq import.workbench
          expect(merge.referentials).to eq import.resources.map(&:referential)
        end
      end
    end
  end

end
