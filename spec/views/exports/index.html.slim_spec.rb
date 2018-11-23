require 'spec_helper'

RSpec.describe "/exports/index", :type => :view do

  let(:ref) { create :workbench_referential }
  let(:workbench) { assign :workbench, ref.workbench }
  let(:context) { { workbench: workbench } }
  let(:exports) do
    assign :exports, build_paginated_collection(:export, ExportDecorator, referential: ref, workbench: workbench, type: "Export::Gtfs", context: context)
  end

  let!(:q) { assign :q, Ransack::Search.new(Export::Base) }
  let!(:types) { assign :types, [Export::Gtfs] }

  before(:each) do
    allow(view).to receive(:collection_name).and_return('exports')
    allow(view).to receive(:collection_class_name).and_return(Export::Base)
    allow(view).to receive(:collection_path).and_return(workbench_exports_path(workbench))
    allow(view).to receive(:collection).and_return(exports)
    allow(view).to receive(:decorated_collection).and_return(exports)
    allow(view).to receive(:params).and_return({action: :index})
    controller.request.path_parameters[:workbench_id] = workbench.id
    controller.request.path_parameters[:action] = "index"
    render
  end

  context "referential name" do
    context "export with referential" do
      xit "should have referential name on page" do
        exports.each_with_index do |export, index|
          ref_link = link_to(export.referential.name, href: referential_path(export.referential))
          expect(export.referential.present?).to be_truthy
          expect(view).to have_link(export.referential.name, href: referential_path(export.referential))
          expect(view).to have_link(export.name, href: workbench_export_path(export))
        end
      end
    end
    context "export without referential" do
      before(:each) do
        ref.destroy
      end
      xit "should not have show link(s) to redirect to show page" do
        exports.each_with_index do |export, index|
          expect(export.reload.referential.present?).to be_falsy
          expect(view).not_to have_link(export.referential.name, href: referential_path(export.referential))
          expect(view).to have_link(export.name, href: workbench_export_path(export))
          expect(view).to have_xpath("//tr[contains(concat(' ',normalize-space(@cla#ss),' '),' base ')][#{index + 1}]/td[4][contains(., '-')]")
        end
      end
    end
  end
end