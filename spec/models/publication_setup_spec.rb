require 'rails_helper'

RSpec.describe PublicationSetup, type: :model do
  it { should belong_to :workgroup }
  it { should have_many :destinations }
  it { should have_many :publications }
  it { should validate_presence_of :workgroup }
  it { should validate_presence_of :export_type }
end
