defmodule Catex.Repo do
  use Ecto.Repo,
    otp_app: :catex,
    adapter: Ecto.Adapters.Postgres

  #  use ExAudit.Repo
end
