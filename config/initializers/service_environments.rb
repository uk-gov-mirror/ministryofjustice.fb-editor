Rails.application.config.platform_environments =
  ActiveSupport::HashWithIndifferentAccess.new({
    live: {
      url_root: 'form.service.justice.gov.uk'
    },
    test: {
      url_root: 'test.form.service.justice.gov.uk'
    },
    local: {
      url_root: 'test.form.service.justice.gov.uk'
    },
    common: {
      namespace: 'formbuilder-services-%{platform_environment}-%{deployment_environment}',
      user_datastore_url: "http://fb-user-datastore-api-svc-%{platform_environment}-%{deployment_environment}.formbuilder-platform-%{platform_environment}-%{deployment_environment}/",
      container_port: 3000
    }
  })

Rails.application.config.deployment_environments = %w(dev production)
