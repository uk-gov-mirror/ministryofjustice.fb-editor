FROM ruby:2.7.2-alpine3.12

ARG UID=1001

RUN apk add git nodejs yarn build-base postgresql-contrib postgresql-dev bash libcurl curl

ARG KUBE_VERSION="1.17.3"
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v$KUBE_VERSION/bin/linux/amd64/kubectl
RUN chmod u+x kubectl && mv kubectl /bin/kubectl

RUN addgroup -g ${UID} -S appgroup && \
  adduser -u ${UID} -S appuser -G appgroup

RUN chown appuser:appgroup /bin/kubectl

WORKDIR /app

RUN chown appuser:appgroup /app

ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2019-root.pem ./rds-ca-2019-root.pem
ADD --chown=appuser:appgroup https://s3.amazonaws.com/rds-downloads/rds-ca-2015-root.pem ./rds-ca-2015-root.pem
RUN cat ./rds-ca-2019-root.pem > ./rds-ca-bundle-root.crt
RUN cat ./rds-ca-2015-root.pem >> ./rds-ca-bundle-root.crt
RUN chown appuser:appgroup ./rds-ca-bundle-root.crt

COPY --chown=appuser:appgroup Gemfile Gemfile.lock .ruby-version ./

RUN gem install bundler

RUN bundle config set no-cache 'true'
ARG BUNDLE_ARGS='--jobs 2 --without test development'
RUN bundle install ${BUNDLE_ARGS}

COPY --chown=appuser:appgroup . .

USER ${UID}

ARG RAILS_ENV=production
CMD bin/delayed_job run
