defmodule Xplr1.Repo do
  use Ecto.Repo,
    otp_app: :xplr1,
    adapter: Ecto.Adapters.Postgres
end
