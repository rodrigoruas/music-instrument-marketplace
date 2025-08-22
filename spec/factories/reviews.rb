FactoryBot.define do
  factory :review do
    rental { nil }
    reviewer { nil }
    reviewee { nil }
    rating { 1 }
    comment { "MyText" }
  end
end
