require 'spec_helper'

describe "/companies/new", :type => :view do

  let!(:company) { assign(:company, build(:company)) }
  let!(:line_referential) { assign :line_referential, company.line_referential }

  describe "form" do

    it "should render input for name" do
      render
      expect(rendered).to have_selector("form") do
        with_selector "input[type=text][name=?]", company.name
      end
    end

  end
end
