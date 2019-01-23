FactoryGirl.define do
  factory :netex_export, class: Export::Netex, parent: :export do
    association :referential, factory: :workbench_referential
    export_type :line
    duration 90

    trait :with_parent do
      association :parent, factory: :workgroup_export
    end
  end
end
