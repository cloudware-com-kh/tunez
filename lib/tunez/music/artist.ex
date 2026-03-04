defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo
  end

  actions do
    defaults [:read, :destroy, :create, :update]
    default_accept [:name, :biography]
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string
    attribute :biography, :string
    timestamps()
  end
end
