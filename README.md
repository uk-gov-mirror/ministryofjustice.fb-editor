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
