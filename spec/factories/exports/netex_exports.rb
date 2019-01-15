FactoryGirl.define do
  factory :netex_export, class: Export::Netex, parent: :export do
    association :parent, factory: :workgroup_export
    options({export_type: :line, duration: 90})
    type 'Export::Netex'
  end
end
