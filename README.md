# Catex

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Production

Copy `.env.template` to `.env` and set the env variables.

Set the oauth credentials in `config/prod.exs`.

Now run the server.

	docker-compose up

Migrations can be applied with `./run prod:migrate`.
