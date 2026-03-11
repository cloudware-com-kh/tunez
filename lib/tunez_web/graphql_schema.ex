defmodule TunezWeb.GraphqlSchema do
  use Absinthe.Schema

  use AshGraphql,
    domains: [Tunez.Music, Tunez.Accounts]

  import_types Absinthe.Plug.Types

  query do
  end

  mutation do
  end

  subscription do
  end
end
