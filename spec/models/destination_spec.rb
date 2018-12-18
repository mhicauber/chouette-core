require 'rails_helper'

RSpec.describe Destination, type: :model do
  it { should belong_to :publication_setup }
  it { should validate_presence_of :publication_setup }
  it { should validate_presence_of :type }
  it { should validate_presence_of :name }
end
