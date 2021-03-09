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

    trait :service_email_subject do
      name { 'SERVICE_EMAIL_SUBJECT' }
      value { "Aren’t you a little short for a Stormtrooper?" }
    end

    trait :service_email_output do
      name { 'SERVICE_EMAIL_OUTPUT' }
      value { "wookies@grrrrr.uk" }
    end

    trait :service_email_body do
      name { 'SERVICE_EMAIL_BODY' }
      value { 'Why, you stuck-up, half-witted, scruffy-looking nerf herder' }
    end

    trait :service_email_pdf_heading do
      name { 'SERVICE_EMAIL_PDF_HEADING' }
      value { 'Star killer complaints' }
    end

    trait :service_email_pdf_subheading do
      name { 'SERVICE_EMAIL_PDF_SUBHEADING' }
      value { 'Star killer HR' }
    end
  end
end
