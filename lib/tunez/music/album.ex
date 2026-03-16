defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  graphql do
    type :album
  end

  json_api do
    type "album"
    includes [:tracks]
  end

  postgres do
    table "albums"
    repo Tunez.Repo

    references do
      reference :artist, index?: true, on_delete: :delete
      reference :created_by, index?: true
      reference :updated_by, index?: true
    end
  end

  actions do
    defaults [:read, :destroy]
    default_accept [:name, :year_released, :cover_image_url]

    create :create do
      accept [:name, :year_released, :cover_image_url]
      argument :artist_id, :uuid, allow_nil?: false
      argument :tracks, {:array, :map}
      change manage_relationship(:artist_id, :artist, type: :append_and_remove)
      change manage_relationship(:tracks, type: :direct_control, order_is_key: :order)
    end

    update :update do
      accept [:name, :year_released, :cover_image_url]
      require_atomic? false
      argument :tracks, {:array, :map}
      change manage_relationship(:tracks, type: :direct_control, order_is_key: :order)
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action([:update, :destroy]) do
      authorize_if expr(created_by_id == ^actor(:id) and ^actor(:role) == :editor)
    end
  end

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true)
  end

  validations do
    validate numericality(:year_released,
               greater_than: 1950,
               less_than_or_equal_to: &__MODULE__.next_year/0
             ),
             where: [present(:year_released)],
             message: "must be between 1950 and next year"

    validate match(:cover_image_url, "^(https://|/images/).+(\.png|\.jpg)$"),
      where: [changing(:cover_image_url)],
      message: "must start with https:// or /images/"
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false, public?: true
    attribute :year_released, :integer, allow_nil?: false, public?: true
    attribute :cover_image_url, :string, public?: true
    timestamps(public?: true)
  end

  relationships do
    belongs_to :artist, Tunez.Music.Artist do
      allow_nil? false
      public? true
    end

    has_many :tracks, Tunez.Music.Track do
      sort order: :asc
      public? true
    end

    belongs_to :created_by, Tunez.Accounts.User
    belongs_to :updated_by, Tunez.Accounts.User
  end

  def next_year, do: Date.utc_today().year + 1

  calculations do
    calculate :years_ago, :integer, expr(2025 - year_released), public?: true

    calculate :string_years_ago,
              :string,
              expr("wow, this was released " <> years_ago <> " years ago!"),
              public?: true

    calculate :duration, :string, Tunez.Music.Calculations.SecondsToMinutes
  end

  aggregates do
    sum :duration_seconds, :tracks, :duration_seconds
  end

  identities do
    identity :unique_album_names_per_artist, [:name, :artist_id],
      message: "already exists for this artist"
  end
end
