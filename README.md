# Fb Editor

New editor from the MoJ online.

## Setup
Ensure you are running on Node version 10.17.0:
`nvm use 10.17.0`

Install webpack assets:
`yarn install`

Copy the environment variables into your own .env file:
`cp .env.development .env`

Install the gems, create migrate the test database and start the Rails server:
    ```
      bundle
      bundle exec rails db:create db:migrate
      bundle exec rails s
    ```

This application talks to the [fb-metadata-api](https://github.com/ministryofjustice/fb-metadata-api) project. You will need to clone this and run the following:

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
