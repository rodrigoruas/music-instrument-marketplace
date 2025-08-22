FactoryBot.define do
  factory :rental do
    instrument { nil }
    renter { nil }
    start_date { "2025-08-22" }
    end_date { "2025-08-22" }
    total_amount { "9.99" }
    status { 1 }
    payment_intent_id { "MyString" }
  end
end
