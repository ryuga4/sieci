defmodule Sieci.Repo do
  use Ecto.Repo,
    otp_app: :sieci,
    adapter: Ecto.Adapters.Postgres
end
