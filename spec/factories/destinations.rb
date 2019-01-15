FactoryGirl.define do
  factory :destination do
    association :publication_setup
    name "MyString"
    type "Destination::Dummy"
    options nil
    secret_file nil
  end

  factory :publication_api_destination, parent: :destination, class: 'Destination::PublicationApi'
end
