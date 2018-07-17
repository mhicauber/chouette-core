FactoryGirl.define do
  factory :api_key, class: ApiKey do
    name  { SecureRandom.urlsafe_base64 }
  end
end
