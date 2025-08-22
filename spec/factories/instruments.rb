FactoryBot.define do
  factory :instrument do
    owner { nil }
    name { "MyString" }
    brand { "MyString" }
    model { "MyString" }
    category { 1 }
    condition { 1 }
    description { "MyText" }
    daily_rate { "9.99" }
    weekly_rate { "9.99" }
    monthly_rate { "9.99" }
    available { false }
    location { "MyString" }
    latitude { "9.99" }
    longitude { "9.99" }
    slug { "MyString" }
  end
end
