defmodule Tunez.Generator do
  use Ash.Generator

  def user(opts \\ []) do
    changeset_generator(
      Tunez.Accounts.User,
      :register_with_password,
      defaults: [
        email: sequence(:user_email, &"user#{&1}@example.com"),
        password: "password",
        password_confirmation: "password"
      ],
      overrides: opts,
      after_action: fn user ->
        role = opts[:role] || :user
        Tunez.Accounts.set_user_role!(user, role, authorize?: false)
      end
    )
  end

  def artist(opts \\ []) do
    actor = opts[:actor] || once(:default_actor, fn -> generate(user(role: :admin)) end)

    after_action =
      if opts[:album_count] do
        fn artist ->
          generate_many(album(artist_id: artist.id), opts[:album_count])
          Ash.load!(artist, :albums)
        end
      end

    if opts[:seed?] do
      seed_generator(
        %Tunez.Music.Artist{
          name: sequence(:artist_name, &"Artist #{&1}")
        },
        actor: actor,
        overrides: opts,
        after_action: after_action
      )
    else
      changeset_generator(
        Tunez.Music.Artist,
        :create,
        defaults: [
          name: sequence(:artist_name, &"Artist #{&1}")
        ],
        actor: actor,
        overrides: opts,
        after_action: after_action
      )
    end
  end

  def album(opts \\ []) do
    actor =
      opts[:actor] ||
        once(:default_actor, fn ->
          generate(user(role: opts[:actor_role] || :editor))
        end)

    artist_id =
      opts[:artist_id] ||
        once(:default_artist_id, fn ->
          generate(artist()).id
        end)

    changeset_generator(
      Tunez.Music.Album,
      :create,
      defaults: [
        name: sequence(:album_name, &"Album #{&1}"),
        year_released: StreamData.integer(1951..2024),
        artist_id: artist_id,
        cover_image_url: nil
      ],
      actor: actor,
      overrides: opts
    )
  end
end
