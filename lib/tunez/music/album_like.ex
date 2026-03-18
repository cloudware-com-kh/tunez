defmodule Tunez.Music.AlbumLike do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "album_likes"
    repo Tunez.Repo

    references do
      reference :album, index?: true, on_delete: :delete
      reference :like, index?: true, on_delete: :delete
    end
  end

  actions do
    defaults [:read]

    create :create do
      accept [:album_id]
      change relate_actor(:like, allow_nil?: false)
    end

    destroy :destroy do
      argument :album_id, :uuid, allow_nil?: false
      change filter expr(album_id == ^arg(:album_id) and like_id == ^actor(:id))
    end
  end

  policies do
    bypass actor_present() do
      authorize_if always()
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  relationships do
    belongs_to :album, Tunez.Music.Album do
      allow_nil? false
      primary_key? true
    end

    belongs_to :like, Tunez.Accounts.User do
      allow_nil? false
      primary_key? true
    end
  end
end
