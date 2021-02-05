FactoryBot.define do
  factory :service_configuration do
    service_id { SecureRandom.uuid }

    trait :dev do
      deployment_environment { 'dev' }
    end

    trait :production do
      deployment_environment { 'production' }
    end

    trait :username do
      name { ServiceConfiguration::BASIC_AUTH_USER }
      value { 'eC13aW5n' }
    end

    trait :password do
      name { ServiceConfiguration::BASIC_AUTH_PASS }
      value { 'dGllLWZpZ2h0ZXIK' }
    end
  end
end
