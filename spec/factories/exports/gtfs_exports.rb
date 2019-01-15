FactoryGirl.define do
  factory :gtfs_export, class: Export::Gtfs, parent: :export do
    association :parent, factory: :workgroup_export
    options({duration: 90})
    type 'Export::Gtfs'
  end
end
