defmodule Tunez.Music.Track do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  graphql do
    type :track
  end

  json_api do
    type "track"
    default_fields [:number, :name, :duration]
  end

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
      accept [:order, :name, :album_id]
      argument :duration, :string, allow_nil?: false
      # convert duration to seconds in database field
      change Tunez.Music.Changes.MinutesToSeconds, only_when_valid?: true
    end

    update :update do
      primary? true
      accept [:order, :name]
      require_atomic? false
      argument :duration, :string, allow_nil?: false
      change Tunez.Music.Changes.MinutesToSeconds, only_when_valid?: true
    end
  end

  policies do
    # New style
    # policy always() do
    #   authorize_if accessing_from(Tunez.Music.Album, :tracks)
    #   authorize_if action_type(:read)
    # end

    # Old style
    policy accessing_from(Tunez.Music.Album, :tracks) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  preparations do
    prepare build(load: [:number, :duration])
  end

  attributes do
    uuid_primary_key :id
    attribute :order, :integer, allow_nil?: false
    attribute :name, :string, allow_nil?: false, public?: true

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

  calculations do
    calculate :number, :integer, expr(order + 1), public?: true
    calculate :duration, :string, Tunez.Music.Calculations.SecondsToMinutes, public?: true
  end
end
