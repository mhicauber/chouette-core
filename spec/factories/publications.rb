FactoryGirl.define do
  factory :publication do
    association :publication_setup
    association :parent, factory: :aggregate
  end
end
