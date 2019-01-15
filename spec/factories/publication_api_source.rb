FactoryGirl.define do
  factory :publication_api_source do
    association :publication_api
    association :publication
  end
end
