ARG ELIXIR_VERSION=1.13.4
ARG OTP_VERSION=24.3.2
ARG DEBIAN_VERSION=bullseye-20210902-slim

ARG BUILDER_IMAGE="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-debian-${DEBIAN_VERSION}"
ARG RUNNER_IMAGE="debian:${DEBIAN_VERSION}"

FROM ${BUILDER_IMAGE} AS  dev
LABEL maintainer="Maxime Bloch <maintainer.cat@mcbloch.dev>"

# prepare build dir
WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl inotify-tools \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd --create-home elixir \
  && mkdir -p /mix && chown elixir:elixir -R /mix /app

USER elixir

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ARG MIX_ENV="prod"
ENV MIX_ENV="${MIX_ENV}" \
    USER="elixir"

# install mix dependencies
COPY --chown=elixir:elixir mix.* ./
RUN if [ "${MIX_ENV}" = "dev" ]; then \
  mix deps.get; else mix deps.get --only "${MIX_ENV}"; fi

# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY --chown=elixir:elixir config/config.exs config/"${MIX_ENV}".exs config/
RUN mix deps.compile

COPY --chown=elixir:elixir priv priv
COPY --chown=elixir:elixir lib lib
COPY --chown=elixir:elixir assets assets

# compile assets
RUN if [ "${MIX_ENV}" != "dev" ]; then \
      mix assets.deploy; fi

# compile release
RUN if [ "${MIX_ENV}" != "dev" ]; then \
      mix compile; fi

# Changes to config/runtime.exs don't require recompiling the code
COPY config/runtime.exs config/

COPY rel rel
RUN if [ "${MIX_ENV}" != "dev" ]; then \
      mix release; fi

ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 8000

CMD ["iex", "-S", "mix", "phx.server"]

###############################################################################

FROM ${RUNNER_IMAGE} AS prod
LABEL maintainer="Maxime Bloch <maintainer.cat@mcbloch.dev>"

RUN apt-get update \
  && apt-get install -y --no-install-recommends libstdc++6 openssl libncurses5 locales \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean

# Set the locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

WORKDIR /app
RUN chown nobody /app

# set runner ENV
ENV MIX_ENV="prod"

# Only copy the final release from the build stage
COPY --from=dev --chown=nobody:root /app/_build/${MIX_ENV}/rel/catex ./

USER nobody

EXPOSE 8000

CMD ["bin/catex", "start"]
