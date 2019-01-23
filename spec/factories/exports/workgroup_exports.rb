FactoryGirl.define do
  factory :workgroup_export, class: Export::Workgroup, parent: :export do
    duration 90
    association :referential, factory: :workbench_referential
  end
end
