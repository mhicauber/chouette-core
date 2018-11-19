require 'spec_helper'

RSpec.describe "/exports/index", :type => :view do

  let(:ref) { create :workbench_referential }
  let(:exports) do
    assign :exports, build_paginated_collection(:export, ExportDecorator, referential: ref, workbench: ref.workbench, type: "Export::Gtfs")
  end

  let!(:q) { assign :q, Ransack::Search.new(Export::Base) }
  let!(:types) { assign :types, [Export::Gtfs] }

  before(:each) do
    allow(view).to receive(:collection).and_return(exports)
    allow(view).to receive(:decorated_collection).and_return(exports)
    allow(view).to receive(:params).and_return({action: :index})
    controller.request.path_parameters[:workbench_id] = ref.workbench.id
    controller.request.path_parameters[:action] = "index"
  end

  context "links" do
    context "export with referential" do
      xit "should have show link(s) to redirect to show page" do
        exports.each do |export|
          show_link = workbench_export_path(ref.workbench, export)
          expect(view).to have_xpath("//td[@class='name']/a[@href='#{show_link}']")
          expect(view).to have_xpath("//td[@class='actions']/div/div/ul/li/a[@href='#{show_link}']")
        end
      end
    end
    context "export without referential" do
      before(:each) do
        ref.destroy
      end
      xit "should not have show link(s) to redirect to show page" do
        exports.each do |export|
          show_link = workbench_export_path(ref.workbench, export)
          expect(view).not_to have_xpath("//td[@class='name']/a[@href='#{show_link}']")
          expect(view).not_to have_xpath("//td[@class='actions']/div/div/ul/li/a[@href='#{show_link}']")
        end
      end
    end
  end
end