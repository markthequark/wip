defmodule Failer.Repo do
  use Ecto.Repo,
    otp_app: :failer,
    adapter: Ecto.Adapters.Postgres
end
