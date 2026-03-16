defmodule Tunez.Music.Track do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "tracks"
    repo Tunez.Repo

    references do
      reference :album, index?: true, on_delete: :delete
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:order, :name, :duration_seconds, :album_id]
    end

    update :update do
      primary? true
      accept [:order, :name, :duration_seconds]
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :order, :integer, allow_nil?: false
    attribute :name, :string, allow_nil?: false

    attribute :duration_seconds, :integer do
      allow_nil? false
      constraints min: 1
    end

    timestamps()
  end

  relationships do
    belongs_to :album, Tunez.Music.Album do
      allow_nil? false
    end
  end
end
