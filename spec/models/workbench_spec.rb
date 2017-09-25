require 'rails_helper'

RSpec.describe Workbench, :type => :model do
  it 'should have a valid factory' do
    expect(FactoryGirl.build(:workbench)).to be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:organisation) }

  it { should belong_to(:organisation) }
  it { should belong_to(:line_referential) }
  it { should belong_to(:stop_area_referential) }
  it { should belong_to(:output).class_name('ReferentialSuite') }

  it { should have_many(:lines).through(:line_referential) }
  it { should have_many(:networks).through(:line_referential) }
  it { should have_many(:companies).through(:line_referential) }
  it { should have_many(:group_of_lines).through(:line_referential) }

  it { should have_many(:stop_areas).through(:stop_area_referential) }

  context '.lines' do
    let!(:ids) { ['STIF:CODIFLIGNE:Line:C00840', 'STIF:CODIFLIGNE:Line:C00086'] }
    let!(:organisation) { create :organisation, sso_attributes: { functional_scope: ids.to_json } }
    let(:workbench) { create :workbench, organisation: organisation }

    it 'should filter lines based on my organisation functional_scope' do
      ids.insert('STIF:CODIFLIGNE:Line:0000').each do |id|
        create :line, objectid: id, line_referential: workbench.line_referential
      end
      lines = workbench.lines
      expect(lines.count).to eq 2
      expect(lines.map(&:objectid)).to include(*ids)
    end
  end
end
