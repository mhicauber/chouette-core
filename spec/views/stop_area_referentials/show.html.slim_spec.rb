require 'spec_helper'

describe "/stop_area_referentials/show", :type => :view do

  let(:stop_area_referential) do
    stop_area_referential = create(:stop_area_referential)
    assign :stop_area_referential, stop_area_referential.decorate
  end

  before :each do
    controller.request.path_parameters[:id] = stop_area_referential.id
    assign :syncs, stop_area_referential.stop_area_referential_syncs

    allow(view).to receive(:params).and_return({action: :show})
    allow(view).to receive(:resource).and_return(stop_area_referential)
    render template: "stop_area_referentials/show", layout: "layouts/application"
  end

  it "should not present syncing infos and button" do
    expect(rendered).to_not have_selector("a[href=\"#{view.sync_stop_area_referential_path(stop_area_referential)}\"]")
  end

  with_permission "stop_area_referentials.synchronize" do
    it "should present syncing infos and button" do
      expect(rendered).to have_selector("a[href=\"#{view.sync_stop_area_referential_path(stop_area_referential)}\"]", count: 1)
    end
  end
end
