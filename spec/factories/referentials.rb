FactoryGirl.define do
  factory :referential do
    sequence(:name) { |n| "Test #{n}" }
    sequence(:slug) { |n| "test_#{n}" }
    sequence(:prefix) { |n| "test_#{n}" }
    association :line_referential
    association :stop_area_referential
    association :organisation
    time_zone "Europe/Paris"
    ready { true }
    objectid_format "stif_netex"
    transient do
      status :active
    end

    after(:create) do |referential, evaluator|
      referential.send "#{evaluator.status}!"
    end

    factory :workbench_referential do
      association :workbench
      before :create do | ref |
        ref.workbench.update organisation: ref.organisation
      end
    end
  end
end
