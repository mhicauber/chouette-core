require 'rails_helper'

RSpec.describe NotificationRule, type: :model do
  subject { build(:notification_rule) }

  it { should belong_to :workbench }
  it { should belong_to :line }
  it { should validate_presence_of(:workbench) }
  it { should validate_presence_of(:line) }
  it { should validate_presence_of(:notification_type) }
  it { should validate_presence_of(:period) }
end