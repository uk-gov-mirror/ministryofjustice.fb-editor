FactoryBot.define do
  factory :submission_setting do
    service_id { SecureRandom.uuid }

    trait :dev do
      deployment_environment { 'dev' }
    end

    trait :production do
      deployment_environment { 'production' }
    end

    trait :send_email do
      send_email { true }
    end

    trait :do_not_send_email do
      send_email { false }
    end
  end
end
