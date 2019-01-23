FactoryGirl.define do
  factory :gtfs_export, class: Export::Gtfs, parent: :export do
    association :parent, factory: :workgroup_export
    association :referential, factory: :workbench_referential
    duration 90
  end
end
