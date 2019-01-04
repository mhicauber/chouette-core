FactoryGirl.define do
  factory :aggregate do
    association :workgroup
    status { :successful }
    name "MyString"
    referentials { [ create(:referential) ] }
    new nil
  end
end
