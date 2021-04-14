# Fb Editor

New editor from the MoJ online.

## Setup
Ensure you are running on Node version 10.17.0:
`nvm use 10.17.0`

Compile the necessary assets and run webpack:
`make assets`

Copy the environment variables into your own .env file:
`cp .env.development .env`

Install the gems, create migrate the test database and start the Rails server:
    ```
      bundle
      bundle exec rails db:create db:migrate
      bundle exec rails s
    ```

This application talks to the [fb-metadata-api](https://github.com/ministryofjustice/fb-metadata-api) project.

You will need to run the following in the **fb-editor**:

```
docker-compose down
make setup
```
This will spin down any past Docker containers and then spin up new ones.

You should now be able to access the Editor on `localhost:3000`

## Acceptance tests

You need to install the Chromium web driver:

`brew install --cask chromedriver`

There are two ways to run the acceptance tests:

1. Pointing to a local editor
2. Pointing to a remote editor (a test environment for example)

Basically the acceptance tests depends to have a `.env.acceptance_tests` with
the editor url.

These use a acceptance tests specific Dockerfile found in the `acceptance` directory instead of the root level Dockerfile.

### Pointing to a local editor

There is the docker compose with all containers needed for the editor.
In order to run the acceptance tests against a local editor all you need to run
is:

```
  make acceptance
```

### Pointing to a remote editor

The editor has a basic authentication so it needs a user and a password.
This is already added on CircleCI but in case you want to run on your local
machine to point to the test environment you need to run:

```
  export ACCEPTANCE_TESTS_USER='my-user'
  export ACCEPTANCE_TESTS_PASSWORD='my-password'
  make acceptance-ci -s
```

### Docker Compose

There are three docker compose files.

#### docker-compose.yml

This spins up all the required apps necessary including the service token cache and a redis container.

#### docker-compose.unit-tests.yml

This is for the unit tests. It only spins up the database and the editor app.

#### docker-compose.ci.yml

This makes use of the Dockerfile in the `acceptance` directory and is used only in the deployment pipeline.


### Session duration rake task

There is a rake task that removes any sessions that have been inactive for more than 90 minutes.
This rake task is found in `lib/tasks/database.rake`.

We could not use the [built in rails session trim task](https://github.com/rails/activerecord-session_store/blob/master/lib/tasks/database.rake) as this could only be modified in days.

### Remove services script

This is for removing all services and their configuration in a given namespace.

`ruby ./lib/scripts/remove_services.rb <namespace> <target>`

For example, if the pod name for a service is `awesome-form-78b47fc858-cxgfl` and you wanted to remove it from `formbuilder-services-test-dev`:

`ruby ./lib/scripts/remove_services.rb formbuilder-services-test-dev awesome-form`

If target is not provided it will attempt to remove all services within the supplied namespace. This is temporary for now until we have a proper mechanism for removing a service and its configuration. It will not work in production namespaces, developers will need to do those by hand if required.
