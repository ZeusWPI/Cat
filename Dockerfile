FROM hexpm/elixir:1.13.4-erlang-25.0-rc2-debian-bullseye-20210902-slim AS dev

LABEL maintainer="Maxime Bloch <maintainer.cat@mcbloch.dev>"

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl inotify-tools \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd --create-home elixir \
  && mkdir -p /mix && chown elixir:elixir -R /mix /app

USER elixir

RUN mix local.hex --force && mix local.rebar --force

ARG MIX_ENV="prod"
ENV MIX_ENV="${MIX_ENV}" \
    USER="elixir"

COPY --chown=elixir:elixir mix.* ./
RUN if [ "${MIX_ENV}" = "dev" ]; then \
  mix deps.get; else mix deps.get --only "${MIX_ENV}"; fi

COPY --chown=elixir:elixir config/config.exs config/"${MIX_ENV}".exs config/
RUN mix deps.compile

COPY --chown=elixir:elixir . .

RUN if [ "${MIX_ENV}" != "dev" ]; then \
      mix assets.deploy && mix release; fi

ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 8000

CMD ["iex", "-S", "mix", "phx.server"]

###############################################################################

FROM hexpm/elixir:1.13.4-erlang-25.0-rc2-debian-bullseye-20210902-slim AS prod
LABEL maintainer="Maxime Bloch <maintainer.cat@mcbloch.dev>"

WORKDIR /app

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && useradd --create-home elixir \
  && chown elixir:elixir -R /app

USER elixir

ENV USER=elixir

#COPY --chown=elixir:elixir --from=dev /app/priv/static /public
COPY --chown=elixir:elixir --from=dev /app/_build/prod/rel/catex ./
COPY --chown=elixir:elixir bin/docker-entrypoint-web bin/

ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 8000

CMD ["bin/catex", "start"]
