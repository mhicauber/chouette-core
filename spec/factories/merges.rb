FactoryGirl.define do
  factory :merge do
    workbench
    new { factory :referential }
  end
end
