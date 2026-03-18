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
    includes albums: [:tracks]
    derive_filter? false
  end

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end

    references do
      reference :created_by, index?: true
      reference :updated_by, index?: true
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

    policy action(:update) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true)
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

    belongs_to :created_by, Tunez.Accounts.User
    belongs_to :updated_by, Tunez.Accounts.User
    # start many to many with users =========
    has_many :follower_relationships, Tunez.Music.ArtistFollower

    many_to_many :followers, Tunez.Accounts.User do
      join_relationship :follower_relationships
      # source_attribute :id
      # destination_attribute :id
      # source_attribute_on_join_resource :artist_id
      destination_attribute_on_join_resource :follower_id
    end

    # end many to many with users ===========
  end

  calculations do
    calculate :name_length, :integer, expr(fragment("length(?)", name))

    calculate :followed_by_me,
              :boolean,
              expr(exists(follower_relationships, follower_id == ^actor(:id))),
              public?: true
  end

  aggregates do
    sum :album_likes_count, :albums, :likes_count
    count :follower_count, :follower_relationships, public?: true
    count :album_count, :albums, public?: true
    first :latest_album_year_released, :albums, field: :year_released, public?: true
    first :cover_image_url, :albums, field: :cover_image_url, public?: true
  end
end
