require "rails_helper"

RSpec.describe Import::Neptune do

  let(:workbench) do
    create :workbench do |workbench|
      workbench.line_referential.update objectid_format: "netex"
      workbench.stop_area_referential.update objectid_format: "netex"
    end
  end

  def create_import(file)
    i = build_import(file)
    i.save!
    i
  end

  def build_import(file='sample_neptune.zip')
    Import::Neptune.new workbench: workbench, local_file: fixtures_path(file), creator: "test", name: "test"
  end

  before(:each) do
    allow(import).to receive(:save_model).and_wrap_original { |m, *args| m.call(*args); args.first.run_callbacks(:commit) }
  end

  context "when the file is not directly accessible" do
    let(:import) { create_import }

    before(:each) do
      allow(import).to receive(:file).and_return(nil)
    end

    it "should still be able to update the import" do
      import.update status: :failed
      expect(import.reload.status).to eq "failed"
    end
  end

  describe "created referential" do
    let(:import) { build_import }

    before(:each) do
      create :line, line_referential: workbench.line_referential 
    end

    it "is named after the import name" do
      import.name = "Import Name"
      import.create_referential
      expect(import.referential.name).to eq(import.name)
    end
  end
end
