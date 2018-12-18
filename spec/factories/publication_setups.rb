FactoryGirl.define do
  factory :publication_setup do
    workgroup { create(:workgroup) }
    export_type "Export::Gtfs"
    export_options ""
    enabled false
  end
end
