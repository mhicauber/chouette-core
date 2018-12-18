require 'rails_helper'

RSpec.describe Publication, type: :model do
  it { should belong_to :publication_setup }
  it { should belong_to :parent }
  it { should validate_presence_of :publication_setup }
  it { should validate_presence_of :parent }
end
