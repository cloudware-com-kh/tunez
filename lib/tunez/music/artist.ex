defmodule Tunez.Music.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  graphql do
    type :artist
  end

  json_api do
    type "artist"
    includes [:albums]
    derive_filter? false
  end

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end

    references do
      reference :user, index?: true, on_delete: :delete
    end
  end

  resource do
    description "A person or group of people that makes and releases music."
  end

  actions do
    defaults [:read]

    read :search do
      description "List Artists, optionally filtering by name."

      argument :query, :ci_string do
        description "Return only artists with names including the given value."

        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))
      pagination offset?: true, default_limit: 5
    end

    create :create do
      accept [:name, :biography]
      change relate_actor(:user, allow_nil?: true)
    end

    update :update do
      accept [:name, :biography]
      require_atomic? false
      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    destroy :destroy do
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action([:create]) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action([:update]) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action(:search) do
      # filter check (sql query) send to query as or statement
      authorize_if relates_to_actor_via(:user)
      # simple check static data (not sql query) more powerful than filter check
      authorize_if actor_attribute_equals(:role, :admin)
    end

    policy action_type([:read]) do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :previous_names, {:array, :string} do
      default []
      public? true
    end

    attribute :biography, :string, public?: true

    timestamps(public?: true)
  end

  relationships do
    has_many :albums, Tunez.Music.Album do
      sort year_released: :desc
      public? true
    end

    belongs_to :user, Tunez.Accounts.User do
      public? true
    end
  end

  calculations do
    # calculate :album_count, :integer, expr(count(albums))
    # calculate :latest_album_year_released, :integer, expr(first(albums, field: :year_released))
    # calculate :cover_image_url, :string, expr(first(albums, field: :cover_image_url))
  end

  aggregates do
    count :album_count, :albums, public?: true
    first :latest_album_year_released, :albums, field: :year_released, public?: true
    first :cover_image_url, :albums, field: :cover_image_url, public?: true
  end
end
