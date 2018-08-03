require 'spec_helper'

describe "referentials/new", :type => :view do

  before(:each) do
    assign(:referential, Referential.new)
    assign(:workbench, create(:workbench))
  end

  it "should have a textfield for name" do
    render
    expect(rendered).to have_field("referential[name]")
  end
end
