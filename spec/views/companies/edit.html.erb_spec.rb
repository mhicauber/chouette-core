require 'spec_helper'

describe "/companies/edit", :type => :view do

  let!(:company) { assign(:company, create(:company)) }
  let!(:companies) { Array.new(2) { create(:company) } }
  let!(:line_referential) { assign :line_referential, company.line_referential }
  before do
    allow(view).to receive(:resource){ company }
    allow(view).to receive(:current_referential){ first_referential }
  end
  describe "form" do
    it "should render input for name" do
      render
      expect(rendered).to have_selector("form") do
        with_tag "input[type=text][name='company[name]'][value=?]", company.name
      end
    end
  end
end
